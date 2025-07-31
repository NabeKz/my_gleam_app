import gleam/list
import gleam/string
import gleeunit
import gleeunit/should

import order_processing/core/shared/validate

pub fn main() {
  gleeunit.main()
}

pub type ProductInfo {
  ProductInfo(id: String, name: String, price: Int)
}

// use構文を使った複数バリデーション（冗長なbindなし）

pub fn use_syntax_success_test() {
  let result = {
    use id <- validate.string_length(validate.valid("prod-001"), 1, 50, "Product ID")
    use name <- validate.non_empty_string(validate.valid("Test Product"), "Product Name")
    use price <- validate.positive_int(validate.valid(1000), "Price")
    validate.valid(ProductInfo(id, name, price))
  }

  let converted = validate.to_result(result)
  case converted {
    Ok(product) -> {
      should.equal("prod-001", product.id)
      should.equal("Test Product", product.name)
      should.equal(1000, product.price)
    }
    Error(errors) ->
      should.equal(
        "Expected success",
        "but got errors: " <> string.join(errors, ", "),
      )
  }
}

pub fn use_syntax_failure_test() {
  let result = {
    use id <- validate.string_length(validate.valid(""), 1, 50, "Product ID")
    // 失敗
    use name <- validate.non_empty_string(validate.valid("Test Product"), "Product Name")
    use price <- validate.positive_int(validate.valid(1000), "Price")
    validate.valid(ProductInfo(id, name, price))
  }

  let converted = validate.to_result(result)
  case converted {
    Error(errors) -> {
      should.equal(1, list.length(errors))
      should.equal(
        "Product ID must be between 1 and 50 characters",
        list.first(errors) |> should.be_ok,
      )
    }
    Ok(_) -> should.equal("Expected failure", "but got success")
  }
}

// 複数エラー収集のテスト（新しいValidated型で実現）

pub fn multiple_errors_demonstration_test() {
  let result = {
    use id <- validate.string_length(validate.valid(""), 1, 50, "Product ID")
    use name <- validate.non_empty_string(validate.valid(""), "Product Name")
    use price <- validate.positive_int(validate.valid(-10), "Price")
    validate.valid(ProductInfo(id, name, price))
  }

  let converted = validate.to_result(result)
  case converted {
    Error(errors) -> {
      should.equal(3, list.length(errors))
      should.be_true(list.contains(errors, "Product ID must be between 1 and 50 characters"))
      should.be_true(list.contains(errors, "Product Name cannot be empty"))
      should.be_true(list.contains(errors, "Price must be positive"))
    }
    Ok(_) -> should.equal("Expected failure", "but got success")
  }
}

// Result型変換のテスト

pub fn to_result_success_test() {
  let validated = validate.valid("success")
  let result = validate.to_result(validated)
  should.equal(Ok("success"), result)
}

pub fn to_result_failure_test() {
  let validated = validate.Validated("field", ["error1", "error2"], fn() { "value" })
  let result = validate.to_result(validated)
  should.equal(Error(["error1", "error2"]), result)
}

pub fn to_single_error_result_test() {
  let validated = validate.Validated("field", ["error1", "error2"], fn() { "value" })
  let result = validate.to_single_error_result(validated)
  should.equal(Error("error1"), result)
}

// 実用的な使用方法のデモ

pub fn practical_email_validation_test() {
  let result = {
    use email <- validate.email(validate.valid("user@example.com"), "Email")
    use _ <- validate.string_length(validate.valid(email), 5, 100, "Email")
    validate.valid(email)
  }

  let converted = validate.to_result(result)
  case converted {
    Ok(email) -> should.equal("user@example.com", email)
    Error(errors) ->
      should.equal(
        "Expected success",
        "but got errors: " <> string.join(errors, ", "),
      )
  }
}
