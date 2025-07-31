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

// 新しいAPIでの基本的なバリデーションチェーン

pub fn chain_validation_success_test() {
  let result = 
    validate.success("prod-001")
    |> validate.string_length(1, 50, "Product ID")
    |> validate.non_empty_string("Product ID")
    |> validate.run()

  case result {
    Ok(product_id) -> {
      should.equal("prod-001", product_id)
    }
    Error(errors) ->
      should.equal(
        "Expected success",
        "but got errors: " <> string.join(errors, ", "),
      )
  }
}

pub fn chain_validation_failure_test() {
  let result = 
    validate.success("")
    |> validate.string_length(1, 50, "Product ID")
    |> validate.non_empty_string("Product ID")
    |> validate.run()

  case result {
    Error(errors) -> {
      should.equal(2, list.length(errors))
      should.be_true(list.contains(errors, "Product ID must be between 1 and 50"))
      should.be_true(list.contains(errors, "Product ID cannot be empty"))
    }
    Ok(_) -> should.equal("Expected failure", "but got success")
  }
}

// field関数を使った複数フィールドのバリデーション

pub fn multiple_fields_validation_test() {
  let product_data = ProductInfo("prod-001", "Test Product", 1000)
  
  let id_validation = 
    validate.success(product_data.id)
    |> validate.string_length(1, 50, "Product ID")
    |> validate.non_empty_string("Product ID")
  
  let name_validation = 
    validate.success(product_data.name)
    |> validate.non_empty_string("Product Name")
    |> validate.string_length(1, 100, "Product Name")
  
  let price_validation = 
    validate.success(product_data.price)
    |> validate.positive_int("Price")
    |> validate.int_range(1, 100000, "Price")
  
  // 各フィールドのバリデーション結果を組み合わせる
  let combined_result = 
    validate.success(ProductInfo)
    |> validate.field(fn(_) { id_validation })
    |> validate.field(fn(_) { name_validation })
    |> validate.field(fn(_) { price_validation })
    |> validate.run()
  
  case combined_result {
    Ok(_product) -> should.be_true(True) // 成功
    Error(errors) ->
      should.equal(
        "Expected success",
        "but got errors: " <> string.join(errors, ", "),
      )
  }
}

// Result型変換のテスト

pub fn run_success_test() {
  let validated = validate.success("success")
  let result = validate.run(validated)
  should.equal(Ok("success"), result)
}

pub fn run_failure_test() {
  let validated = validate.Validated("field", ["error1", "error2"], fn() { "value" })
  let result = validate.run(validated)
  should.equal(Error(["error1", "error2"]), result)
}

pub fn to_result_success_test() {
  let validated = validate.success("success") 
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
  let result = 
    validate.success("user@example.com")
    |> validate.email("Email")
    |> validate.string_length(5, 100, "Email")
    |> validate.run()

  case result {
    Ok(email) -> should.equal("user@example.com", email)
    Error(errors) ->
      should.equal(
        "Expected success",
        "but got errors: " <> string.join(errors, ", "),
      )
  }
}

// 複数エラー収集のデモンストレーション
pub fn multiple_errors_collection_test() {
  let result = 
    validate.success("")
    |> validate.string_length(5, 50, "Username")
    |> validate.non_empty_string("Username")
    |> validate.run()

  case result {
    Error(errors) -> {
      should.equal(2, list.length(errors))
      should.be_true(list.contains(errors, "Username must be between 5 and 50"))
      should.be_true(list.contains(errors, "Username cannot be empty"))
    }
    Ok(_) -> should.equal("Expected failure", "but got success")
  }
}

// 整数バリデーションのテスト
pub fn integer_validation_test() {
  let result = 
    validate.success(-10)
    |> validate.positive_int("Age")
    |> validate.int_range(18, 120, "Age")
    |> validate.run()

  case result {
    Error(errors) -> {
      should.equal(2, list.length(errors))
      should.be_true(list.contains(errors, "Age must be positive"))
      should.be_true(list.contains(errors, "Age must be between 18 and 120"))
    }
    Ok(_) -> should.equal("Expected failure", "but got success")
  }
}

// メールバリデーションのテスト
pub fn email_validation_failure_test() {
  let result = 
    validate.success("invalid-email")
    |> validate.email("Email")
    |> validate.run()

  case result {
    Error(errors) -> {
      should.equal(1, list.length(errors))
      should.equal("Email has invalid email address format", list.first(errors) |> should.be_ok)
    }
    Ok(_) -> should.equal("Expected failure", "but got success")
  }
}

// 文字列長チェックのみのテスト
pub fn string_length_only_test() {
  let short_result = 
    validate.success("ab")
    |> validate.string_length(5, 10, "Password")
    |> validate.run()

  let long_result = 
    validate.success("this_is_very_long_password")
    |> validate.string_length(5, 10, "Password")
    |> validate.run()

  let valid_result = 
    validate.success("valid")
    |> validate.string_length(5, 10, "Password")
    |> validate.run()

  case short_result {
    Error(errors) -> should.equal("Password must be between 5 and 10", list.first(errors) |> should.be_ok)
    Ok(_) -> should.equal("Expected failure", "but got success")
  }

  case long_result {
    Error(errors) -> should.equal("Password must be between 5 and 10", list.first(errors) |> should.be_ok)  
    Ok(_) -> should.equal("Expected failure", "but got success")
  }

  case valid_result {
    Ok(password) -> should.equal("valid", password)
    Error(_) -> should.equal("Expected success", "but got failure")
  }
}