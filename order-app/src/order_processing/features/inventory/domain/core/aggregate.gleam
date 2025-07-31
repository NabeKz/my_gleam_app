import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string

import order_processing/core/shared/validate
import order_processing/features/inventory/domain/core/events.{
  type InventoryEvent, type StockReservation,
}
import order_processing/features/inventory/domain/core/value_objects.{
  type ProductId, type ProductInfo, type ProductName, type StockLevel,
  type StockStatus, Available, OutOfStock, Reserved,
}

/// 在庫アイテムアグリゲート
pub type InventoryItem {
  InventoryItem(
    product_id: ProductId,
    product_name: ProductName,
    available_quantity: Int,
    reserved_quantity: Int,
    total_quantity: Int,
    status: StockStatus,
    reservations: List(StockReservation),
    version: Int,
  )
}

/// 初期の在庫アイテムを作成
pub fn create_initial_item(
  product_id: ProductId,
  product_name: ProductName,
) -> InventoryItem {
  InventoryItem(
    product_id: product_id,
    product_name: product_name,
    available_quantity: 0,
    reserved_quantity: 0,
    total_quantity: 0,
    status: OutOfStock,
    reservations: [],
    version: 0,
  )
}

/// イベントから在庫アイテムを復元するための初期値を作成
pub fn create_initial_item_from_id(
  product_id: String,
) -> Result(InventoryItem, String) {
  use pid <- result.try(
    value_objects.create_product_id(product_id)
    |> result.map_error(fn(errors) { 
      "Invalid product_id: " <> {
        errors |> list.map(validate.to_string) |> string.join(", ")
      }
    }),
  )
  use pname <- result.try(
    value_objects.create_product_name("Unknown Product")
    |> result.map_error(fn(errors) { 
      "Failed to create product name: " <> {
        errors |> list.map(validate.to_string) |> string.join(", ")
      }
    }),
  )
  create_initial_item(pid, pname) |> Ok()
}

/// 単一のイベントを適用
pub fn apply_event(item: InventoryItem, event: InventoryEvent) -> InventoryItem {
  case event {
    events.ProductAddedToInventory(
      product_id,
      product_name,
      initial_quantity,
      _,
    ) -> {
      // イベントから値オブジェクトを作成（エラーの場合はunsafe_createでフォールバック）
      let pid = case value_objects.create_product_id(product_id) {
        Ok(id) -> id
        Error(_) -> value_objects.unsafe_create_product_id(product_id)
        // フォールバック
      }
      let pname = case value_objects.create_product_name(product_name) {
        Ok(name) -> name
        Error(_) -> value_objects.unsafe_create_product_name(product_name)
        // フォールバック
      }

      InventoryItem(
        ..item,
        product_id: pid,
        product_name: pname,
        available_quantity: initial_quantity,
        total_quantity: initial_quantity,
        status: case initial_quantity > 0 {
          True -> Available
          False -> OutOfStock
        },
        version: item.version + 1,
      )
    }

    events.StockReceived(_, quantity, _, _) -> {
      let new_available = item.available_quantity + quantity
      let new_total = item.total_quantity + quantity
      InventoryItem(
        ..item,
        available_quantity: new_available,
        total_quantity: new_total,
        status: case new_available > 0 {
          True -> Available
          False ->
            case item.reserved_quantity > 0 {
              True -> Reserved
              False -> OutOfStock
            }
        },
        version: item.version + 1,
      )
    }

    events.StockReserved(_, quantity, reserved_for, reserved_at) -> {
      let new_available = item.available_quantity - quantity
      let new_reserved = item.reserved_quantity + quantity
      let new_reservation =
        events.StockReservation(
          reservation_id: reserved_for,
          product_id: value_objects.product_id_to_string(item.product_id),
          quantity: quantity,
          reserved_for: reserved_for,
          reserved_at: reserved_at,
        )
      InventoryItem(
        ..item,
        available_quantity: new_available,
        reserved_quantity: new_reserved,
        reservations: [new_reservation, ..item.reservations],
        status: case new_available > 0 {
          True -> Available
          False ->
            case new_reserved > 0 {
              True -> Reserved
              False -> OutOfStock
            }
        },
        version: item.version + 1,
      )
    }

    events.StockReservationReleased(_, quantity, reservation_id, _) -> {
      let new_available = item.available_quantity + quantity
      let new_reserved = item.reserved_quantity - quantity
      let updated_reservations =
        list.filter(item.reservations, fn(r) {
          r.reservation_id != reservation_id
        })
      InventoryItem(
        ..item,
        available_quantity: new_available,
        reserved_quantity: new_reserved,
        reservations: updated_reservations,
        status: case new_available > 0 {
          True -> Available
          False ->
            case new_reserved > 0 {
              True -> Reserved
              False -> OutOfStock
            }
        },
        version: item.version + 1,
      )
    }

    events.StockIssued(_, quantity, _, _) -> {
      let new_reserved = item.reserved_quantity - quantity
      let new_total = item.total_quantity - quantity
      InventoryItem(
        ..item,
        reserved_quantity: new_reserved,
        total_quantity: new_total,
        status: case item.available_quantity > 0 {
          True -> Available
          False ->
            case new_reserved > 0 {
              True -> Reserved
              False -> OutOfStock
            }
        },
        version: item.version + 1,
      )
    }

    events.StockAdjusted(_, _, new_quantity, _, _) -> {
      let quantity_diff = new_quantity - item.total_quantity
      let new_available = item.available_quantity + quantity_diff
      InventoryItem(
        ..item,
        available_quantity: new_available,
        total_quantity: new_quantity,
        status: case new_available > 0 {
          True -> Available
          False ->
            case item.reserved_quantity > 0 {
              True -> Reserved
              False -> OutOfStock
            }
        },
        version: item.version + 1,
      )
    }

    events.StockShortage(_, _, _, _) ->
      // 在庫不足イベントは状態を変更しない（記録のみ）
      InventoryItem(..item, version: item.version + 1)
  }
}

/// 在庫が十分にあるかチェック
pub fn has_sufficient_stock(
  item: InventoryItem,
  requested_quantity: Int,
) -> Bool {
  item.available_quantity >= requested_quantity
}

/// 予約可能な数量をチェック
pub fn can_reserve(item: InventoryItem, quantity: Int) -> Bool {
  has_sufficient_stock(item, quantity)
}

/// 特定の予約を取得
pub fn get_reservation(
  item: InventoryItem,
  reservation_id: String,
) -> Option(StockReservation) {
  list.find(item.reservations, fn(r) { r.reservation_id == reservation_id })
  |> option.from_result
}

/// 現在の在庫レベルを取得（値オブジェクト作成が失敗した場合はデフォルト値を使用）
pub fn get_stock_level(item: InventoryItem) -> StockLevel {
  let available = case
    value_objects.create_stock_quantity(item.available_quantity)
  {
    Ok(qty) -> qty
    Error(_) -> value_objects.unsafe_create_stock_quantity(0)
    // フォールバック
  }
  let reserved = case
    value_objects.create_stock_quantity(item.reserved_quantity)
  {
    Ok(qty) -> qty
    Error(_) -> value_objects.unsafe_create_stock_quantity(0)
    // フォールバック
  }
  let total = case value_objects.create_stock_quantity(item.total_quantity) {
    Ok(qty) -> qty
    Error(_) -> value_objects.unsafe_create_stock_quantity(0)
    // フォールバック
  }

  value_objects.StockLevel(
    available: available,
    reserved: reserved,
    total: total,
  )
}

/// 商品情報を取得
pub fn get_product_info(item: InventoryItem) -> ProductInfo {
  value_objects.ProductInfo(
    product_id: item.product_id,
    product_name: item.product_name,
    status: item.status,
  )
}
