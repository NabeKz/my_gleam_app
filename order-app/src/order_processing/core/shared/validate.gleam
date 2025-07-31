import gleam/int
import gleam/list
import gleam/string

/// 複数エラーを収集するためのValidated型
pub type Validated(t) {
  Validated(field_name: String, errors: List(String), function: fn() -> t)
}

/// Validated型をResult型に変換
pub fn to_result(validated: Validated(a)) -> Result(a, List(String)) {
  let Validated(_, errors, function) = validated
  case errors {
    [] -> Ok(function())
    _ -> Error(errors)
  }
}

/// 単一エラー用のResult型に変換（最初のエラーのみ）
pub fn to_single_error_result(validated: Validated(a)) -> Result(a, String) {
  let Validated(_, errors, function) = validated
  case errors {
    [] -> Ok(function())
    [first, ..] -> Error(first)
  }
}

/// use構文対応：文字列の長さをチェック
pub fn string_length(
  validated: Validated(String),
  min_length: Int,
  max_length: Int,
  field_name: String,
) -> Validated(String) {
  let value = validated.function()
  let length = string.length(value)
  let cond = length >= min_length && length <= max_length
  case cond {
    True -> validated
    _ -> {
      let #(min, max) = #(int.to_string(min_length), int.to_string(max_length))
      let error = field_name <> " must be between " <> min <> " and " <> max
      validated
      |> add_error(error)
    }
  }
}

/// use構文対応：空でない文字列をチェック
pub fn non_empty_string(
  validated: Validated(String),
  field_name: String,
) -> Validated(String) {
  let value = validated.function()
  let cond = string.length(value) > 0
  case cond {
    True -> validated
    _ -> {
      validated |> add_error(field_name <> " cannot be empty")
    }
  }
}

/// use構文対応：正の整数をチェック
pub fn positive_int(
  validated: Validated(Int),
  field_name: String,
) -> Validated(Int) {
  let value = validated.function()
  let cond = value > 0

  case cond {
    True -> validated
    _ -> {
      let error = field_name <> " must be positive"
      add_error(validated, error)
    }
  }
}

/// use構文対応：整数の範囲をチェック
pub fn int_range(
  validated: Validated(Int),
  min_value: Int,
  max_value: Int,
  field_name: String,
) -> Validated(Int) {
  let value = validated.function()
  let cond = value >= min_value && value <= max_value

  case cond {
    True -> validated
    _ -> {
      let error =
        field_name
        <> " must be between "
        <> int.to_string(min_value)
        <> " and "
        <> int.to_string(max_value)

      add_error(validated, error)
    }
  }
}

/// use構文対応：メールアドレスをチェック
pub fn email(
  validated: Validated(String),
  field_name: String,
) -> Validated(String) {
  let value = validated.function()
  let cond = string.contains(value, "@") && string.length(value) > 3

  case cond {
    True -> validated
    False ->
      add_error(validated, field_name <> " has invalid email address format")
  }
}

fn add_error(validated: Validated(a), error: String) -> Validated(a) {
  let errors = [error, ..validated.errors] |> list.reverse()
  Validated(..validated, errors:)
}

pub fn field(validator: Validated(a), f: fn(a) -> Validated(b)) -> Validated(b) {
  let value = validator.function()
  let result = f(value)
  let errors = [validator.errors, result.errors] |> list.flatten

  Validated(..result, errors:)
}

pub fn run(validator: Validated(t)) -> Result(t, List(String)) {
  case validator.errors {
    [] -> Ok(validator.function())
    _ -> Error(validator.errors)
  }
}

pub fn success(value: t) -> Validated(t) {
  Validated(field_name: "success", errors: [], function: fn() { value })
}
