import gleam/list
import gleam/string
import gleeunit
import gleeunit/should

import order_processing/core/shared/validate
import order_processing/features/inventory/domain/core/value_objects

pub fn main() {
  gleeunit.main()
}

pub fn create_stock_level_valid_test() {
  let result = value_objects.create_stock_level(10, 5)

  result
  |> should.be_ok()
}

pub fn create_stock_level_single_error_test() {
  let result = value_objects.create_stock_level(-1, 5)

  case result {
    Ok(_) -> should.fail()
    Error(errors) -> {
      errors
      |> should.not_equal([])
      // available に1つのエラーがあることを確認
    }
  }
}

pub fn create_stock_level_multiple_errors_test() {
  // 複数フィールドでエラー: available = -1, reserved = -2
  let result = value_objects.create_stock_level(-1, -2)

  case result {
    Ok(_) -> should.fail()
    Error(errors) -> {
      errors
      |> should.not_equal([])

      // 複数のエラーが返されることを確認
      let error_count = errors |> list.length()
      should.be_true(error_count > 1)

      // 正しいフィールド名が含まれることを確認
      let error_messages =
        errors
        |> list.map(validate.to_string)
        |> string.join(", ")

      // "available" と "reserved" のフィールド名が含まれていることを確認
      should.be_true(string.contains(error_messages, "available"))
      should.be_true(string.contains(error_messages, "reserved"))
    }
  }
}
