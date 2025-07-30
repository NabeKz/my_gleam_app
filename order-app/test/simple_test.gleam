import gleam/option.{None}
import gleam/time/calendar
import gleeunit
import gleeunit/should

import order_processing/features/ship_order/domain/logic/command_handlers
import order_processing/features/ship_order/domain/logic/commands

pub fn main() {
  gleeunit.main()
}

// テスト用のヘルパー関数
fn create_test_date() -> calendar.Date {
  let assert Ok(month) = calendar.month_from_int(1)
  calendar.Date(year: 2024, month: month, day: 15)
}

// 基本的なテスト：存在しない注文をバリデーションしようとするとエラーになる
pub fn validate_nonexistent_order_test() {
  let command = commands.ValidateOrder("nonexistent-order")
  let test_date = create_test_date()

  let result = command_handlers.handle_validate_order(None, command, test_date)

  case result {
    command_handlers.Failure(error) -> {
      should.equal("Order not found", error)
    }
    command_handlers.Success(_) -> {
      // テスト失敗
      should.equal("Expected failure", "but got success")
    }
  }
}

// 基本的なテスト：存在しない注文をキャンセルしようとするとエラーになる  
pub fn cancel_nonexistent_order_test() {
  let command = commands.CancelOrder("nonexistent-order", "Test reason")
  let test_date = create_test_date()

  let result = command_handlers.handle_cancel_order(None, command, test_date)

  case result {
    command_handlers.Failure(error) -> {
      should.equal("Order not found", error)
    }
    command_handlers.Success(_) -> {
      // テスト失敗
      should.equal("Expected failure", "but got success")
    }
  }
}
