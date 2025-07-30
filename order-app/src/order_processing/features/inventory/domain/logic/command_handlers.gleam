import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/time/calendar

import order_processing/features/inventory/domain/core/aggregate
import order_processing/features/inventory/domain/core/events
import order_processing/features/inventory/domain/core/value_objects
import order_processing/features/inventory/domain/logic/commands

/// コマンド処理結果
pub type CommandResult {
  Success(events: List(events.InventoryEvent))
  Failure(error: String)
}

/// 商品追加コマンドを処理
pub fn handle_add_product(
  current_item: Option(aggregate.InventoryItem),
  command: commands.InventoryCommand,
  current_date: calendar.Date,
) -> CommandResult {
  case current_item {
    Some(_) -> Failure("Product already exists in inventory")
    None -> {
      let assert commands.AddProductToInventory(product_id, product_name, initial_quantity) = command

      // バリデーション
      let validations = [
        validate_product_id(product_id),
        validate_product_name(product_name),
        validate_quantity(initial_quantity),
      ]

      case combine_validations(validations) {
        Ok(_) -> {
          let event = events.ProductAddedToInventory(
            product_id: product_id,
            product_name: product_name,
            initial_quantity: initial_quantity,
            added_at: current_date,
          )
          Success([event])
        }
        Error(error) -> Failure(error)
      }
    }
  }
}

/// 入庫コマンドを処理
pub fn handle_receive_stock(
  current_item: Option(aggregate.InventoryItem),
  command: commands.InventoryCommand,
  current_date: calendar.Date,
) -> CommandResult {
  case current_item {
    None -> Failure("Product not found in inventory")
    Some(_item) -> {
      let assert commands.ReceiveStock(product_id, quantity, received_from) = command

      // バリデーション
      let validations = [
        validate_quantity(quantity),
        validate_received_from(received_from),
      ]

      case combine_validations(validations) {
        Ok(_) -> {
          let event = events.StockReceived(
            product_id: product_id,
            quantity: quantity,
            received_from: received_from,
            received_at: current_date,
          )
          Success([event])
        }
        Error(error) -> Failure(error)
      }
    }
  }
}

/// 在庫予約コマンドを処理
pub fn handle_reserve_stock(
  current_item: Option(aggregate.InventoryItem),
  command: commands.InventoryCommand,
  current_date: calendar.Date,
) -> CommandResult {
  case current_item {
    None -> Failure("Product not found in inventory")
    Some(item) -> {
      let assert commands.ReserveStock(product_id, quantity, reserved_for) = command

      // バリデーション
      let validations = [
        validate_quantity(quantity),
        validate_reserved_for(reserved_for),
      ]

      case combine_validations(validations) {
        Ok(_) -> {
          // 在庫十分性チェック
          case aggregate.can_reserve(item, quantity) {
            True -> {
              let event = events.StockReserved(
                product_id: product_id,
                quantity: quantity,
                reserved_for: reserved_for,
                reserved_at: current_date,
              )
              Success([event])
            }
            False -> {
              // 在庫不足イベントも生成
              let shortage_event = events.StockShortage(
                product_id: product_id,
                requested_quantity: quantity,
                available_quantity: item.available_quantity,
                detected_at: current_date,
              )
              Success([shortage_event])
            }
          }
        }
        Error(error) -> Failure(error)
      }
    }
  }
}

/// 予約解除コマンドを処理
pub fn handle_release_reservation(
  current_item: Option(aggregate.InventoryItem),
  command: commands.InventoryCommand,
  current_date: calendar.Date,
) -> CommandResult {
  case current_item {
    None -> Failure("Product not found in inventory")
    Some(item) -> {
      let assert commands.ReleaseStockReservation(product_id, quantity, reservation_id) = command

      // 予約の存在確認
      case aggregate.get_reservation(item, reservation_id) {
        Some(reservation) -> {
          case reservation.quantity == quantity {
            True -> {
              let event = events.StockReservationReleased(
                product_id: product_id,
                quantity: quantity,
                reservation_id: reservation_id,
                released_at: current_date,
              )
              Success([event])
            }
            False -> Failure("Quantity mismatch with reservation")
          }
        }
        None -> Failure("Reservation not found")
      }
    }
  }
}

/// 出庫コマンドを処理
pub fn handle_issue_stock(
  current_item: Option(aggregate.InventoryItem),
  command: commands.InventoryCommand,
  current_date: calendar.Date,
) -> CommandResult {
  case current_item {
    None -> Failure("Product not found in inventory")
    Some(item) -> {
      let assert commands.IssueStock(product_id, quantity, issued_to) = command

      // バリデーション
      let validations = [
        validate_quantity(quantity),
        validate_issued_to(issued_to),
      ]

      case combine_validations(validations) {
        Ok(_) -> {
          // 予約済み在庫から出庫可能かチェック
          case item.reserved_quantity >= quantity {
            True -> {
              let event = events.StockIssued(
                product_id: product_id,
                quantity: quantity,
                issued_to: issued_to,
                issued_at: current_date,
              )
              Success([event])
            }
            False -> Failure("Insufficient reserved stock for issue")
          }
        }
        Error(error) -> Failure(error)
      }
    }
  }
}

/// 在庫調整コマンドを処理
pub fn handle_adjust_stock(
  current_item: Option(aggregate.InventoryItem),
  command: commands.InventoryCommand,
  current_date: calendar.Date,
) -> CommandResult {
  case current_item {
    None -> Failure("Product not found in inventory")
    Some(item) -> {
      let assert commands.AdjustStock(product_id, new_quantity, reason) = command

      // バリデーション
      let validations = [
        validate_quantity(new_quantity),
        validate_adjustment_reason(reason),
      ]

      case combine_validations(validations) {
        Ok(_) -> {
          let event = events.StockAdjusted(
            product_id: product_id,
            old_quantity: item.total_quantity,
            new_quantity: new_quantity,
            reason: reason,
            adjusted_at: current_date,
          )
          Success([event])
        }
        Error(error) -> Failure(error)
      }
    }
  }
}

/// 在庫確認（イベント生成なし）
pub fn handle_check_stock(
  current_item: Option(aggregate.InventoryItem),
  _command: commands.InventoryCommand,
  _current_date: calendar.Date,
) -> CommandResult {
  case current_item {
    None -> Failure("Product not found in inventory")
    Some(_item) -> Success([]) // 確認は成功だがイベントは生成しない
  }
}

// バリデーション関数群

/// 商品IDのバリデーション
fn validate_product_id(product_id: String) -> Result(Nil, String) {
  case value_objects.create_product_id(product_id) {
    Ok(_) -> Ok(Nil)
    Error(error) -> Error(error)
  }
}

/// 商品名のバリデーション
fn validate_product_name(product_name: String) -> Result(Nil, String) {
  case value_objects.create_product_name(product_name) {
    Ok(_) -> Ok(Nil)
    Error(error) -> Error(error)
  }
}

/// 数量のバリデーション
fn validate_quantity(quantity: Int) -> Result(Nil, String) {
  case value_objects.create_stock_quantity(quantity) {
    Ok(_) -> Ok(Nil)
    Error(error) -> Error(error)
  }
}

/// 入庫元のバリデーション
fn validate_received_from(received_from: String) -> Result(Nil, String) {
  case string.length(received_from) > 0 {
    True -> Ok(Nil)
    False -> Error("Received from cannot be empty")
  }
}

/// 予約先のバリデーション
fn validate_reserved_for(reserved_for: String) -> Result(Nil, String) {
  case string.length(reserved_for) > 0 {
    True -> Ok(Nil)
    False -> Error("Reserved for cannot be empty")
  }
}

/// 出庫先のバリデーション
fn validate_issued_to(issued_to: String) -> Result(Nil, String) {
  case string.length(issued_to) > 0 {
    True -> Ok(Nil)
    False -> Error("Issued to cannot be empty")
  }
}

/// 調整理由のバリデーション
fn validate_adjustment_reason(reason: String) -> Result(Nil, String) {
  case string.length(reason) > 0 {
    True -> Ok(Nil)
    False -> Error("Adjustment reason cannot be empty")
  }
}

/// 複数のバリデーション結果を組み合わせる
fn combine_validations(
  validations: List(Result(Nil, String)),
) -> Result(Nil, String) {
  case list.find(validations, fn(result) {
    case result {
      Error(_) -> True
      Ok(_) -> False
    }
  }) {
    Ok(Error(error)) -> Error(error)
    _ -> Ok(Nil)
  }
}