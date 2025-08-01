import gleam/bool
import gleam/list
import gleam/option.{type Option}
import gleam/time/calendar

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
) -> Result(InventoryItem, List(validate.ValidateError)) {
  let pid_result = value_objects.create_product_id(product_id)
  let pname_result = value_objects.create_product_name("Unknown Product")

  case pid_result, pname_result {
    Ok(pid), Ok(pname) -> create_initial_item(pid, pname) |> Ok()
    Error(pid_errors), Ok(_) -> Error(pid_errors)
    Ok(_), Error(pname_errors) -> Error(pname_errors)
    Error(pid_errors), Error(pname_errors) ->
      Error(list.append(pid_errors, pname_errors))
  }
}

/// ステータス計算のヘルパー関数
fn calculate_status(available: Int, reserved: Int) -> StockStatus {
  use <- bool.guard(available > 0, Available)

  case reserved > 0 {
    True -> Reserved
    False -> OutOfStock
  }
}

fn increment_version(item: InventoryItem) -> InventoryItem {
  InventoryItem(..item, version: item.version + 1)
}

/// 単一のイベントを適用
/// ProductAddedToInventory イベントの処理
fn apply_product_added_to_inventory(
  item: InventoryItem,
  product_id: String,
  product_name: String,
  initial_quantity: Int,
) -> Result(InventoryItem, List(validate.ValidateError)) {
  let pid_result = value_objects.create_product_id(product_id)
  let pname_result = value_objects.create_product_name(product_name)

  case pid_result, pname_result {
    Ok(pid), Ok(pname) -> {
      let status = calculate_status(initial_quantity, 0)
      InventoryItem(
        ..item,
        product_id: pid,
        product_name: pname,
        available_quantity: initial_quantity,
        total_quantity: initial_quantity,
        status:,
      )
      |> increment_version()
      |> Ok()
    }
    Error(pid_errors), Ok(_) -> Error(pid_errors)
    Ok(_), Error(pname_errors) -> Error(pname_errors)
    Error(pid_errors), Error(pname_errors) ->
      Error(list.append(pid_errors, pname_errors))
  }
}

/// StockReceived イベントの処理
fn apply_stock_received(
  item: InventoryItem,
  quantity: Int,
) -> Result(InventoryItem, List(validate.ValidateError)) {
  let new_available = item.available_quantity + quantity
  let new_total = item.total_quantity + quantity
  InventoryItem(
    ..item,
    available_quantity: new_available,
    total_quantity: new_total,
    status: calculate_status(new_available, item.reserved_quantity),
  )
  |> increment_version()
  |> Ok()
}

/// StockReserved イベントの処理
fn apply_stock_reserved(
  item: InventoryItem,
  quantity: Int,
  reserved_for: String,
  reserved_at: calendar.Date,
) -> Result(InventoryItem, List(validate.ValidateError)) {
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
    status: calculate_status(new_available, new_reserved),
  )
  |> increment_version()
  |> Ok()
}

/// StockReservationReleased イベントの処理
fn apply_stock_reservation_released(
  item: InventoryItem,
  quantity: Int,
  reservation_id: String,
) -> Result(InventoryItem, List(validate.ValidateError)) {
  let new_available = item.available_quantity + quantity
  let new_reserved = item.reserved_quantity - quantity
  let updated_reservations =
    list.filter(item.reservations, fn(r) { r.reservation_id != reservation_id })
  InventoryItem(
    ..item,
    available_quantity: new_available,
    reserved_quantity: new_reserved,
    reservations: updated_reservations,
    status: calculate_status(new_available, new_reserved),
  )
  |> increment_version()
  |> Ok()
}

/// StockIssued イベントの処理
fn apply_stock_issued(
  item: InventoryItem,
  quantity: Int,
) -> Result(InventoryItem, List(validate.ValidateError)) {
  let new_reserved = item.reserved_quantity - quantity
  let new_total = item.total_quantity - quantity
  InventoryItem(
    ..item,
    reserved_quantity: new_reserved,
    total_quantity: new_total,
    status: calculate_status(item.available_quantity, new_reserved),
  )
  |> increment_version()
  |> Ok()
}

/// StockAdjusted イベントの処理
fn apply_stock_adjusted(
  item: InventoryItem,
  new_quantity: Int,
) -> Result(InventoryItem, List(validate.ValidateError)) {
  let quantity_diff = new_quantity - item.total_quantity
  let new_available = item.available_quantity + quantity_diff
  InventoryItem(
    ..item,
    available_quantity: new_available,
    total_quantity: new_quantity,
    status: calculate_status(new_available, item.reserved_quantity),
  )
  |> increment_version()
  |> Ok()
}

pub fn apply_event(
  item: InventoryItem,
  event: InventoryEvent,
) -> Result(InventoryItem, List(validate.ValidateError)) {
  case event {
    events.ProductAddedToInventory(
      product_id,
      product_name,
      initial_quantity,
      _,
    ) ->
      apply_product_added_to_inventory(
        item,
        product_id,
        product_name,
        initial_quantity,
      )

    events.StockReceived(_, quantity, ..) ->
      apply_stock_received(item, quantity)

    events.StockReserved(_, quantity, reserved_for, reserved_at) ->
      apply_stock_reserved(item, quantity, reserved_for, reserved_at)

    events.StockReservationReleased(_, quantity, reservation_id, _) ->
      apply_stock_reservation_released(item, quantity, reservation_id)

    events.StockIssued(_, quantity, ..) -> apply_stock_issued(item, quantity)

    events.StockAdjusted(_, _, new_quantity, ..) ->
      apply_stock_adjusted(item, new_quantity)

    events.StockShortage(..) ->
      // 在庫不足イベントは状態を変更しない（記録のみ）
      increment_version(item) |> Ok()
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
  }
  let reserved = case
    value_objects.create_stock_quantity(item.reserved_quantity)
  {
    Ok(qty) -> qty
    Error(_) -> value_objects.unsafe_create_stock_quantity(0)
  }
  let total = case value_objects.create_stock_quantity(item.total_quantity) {
    Ok(qty) -> qty
    Error(_) -> value_objects.unsafe_create_stock_quantity(0)
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
