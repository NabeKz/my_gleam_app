import gleam/int
import gleam/list
import gleam/string

/// 複数エラーを収集するためのValidated型
pub type Validated(t) {
  Validated(field_name: String, errors: List(String), function: fn() -> t)
}

/// Validated型をResult型に変換
pub fn to_result(validated: Validated(a)) -> Result(a, List(String)) {
  let Validated(_field_name, errors, function) = validated
  case errors {
    [] -> Ok(function())
    _ -> Error(errors)
  }
}

/// 単一エラー用のResult型に変換（最初のエラーのみ）
pub fn to_single_error_result(validated: Validated(a)) -> Result(a, String) {
  let Validated(_field_name, errors, function) = validated
  case errors {
    [] -> Ok(function())
    [first, ..] -> Error(first)
  }
}

/// 値から初期Validatedを作成
pub fn valid(value: a) -> Validated(a) {
  Validated("", [], fn() { value })
}

/// use構文対応：文字列の長さをチェック
pub fn string_length(
  validated: Validated(String),
  min_length: Int,
  max_length: Int,
  field_name: String,
  continue: fn(String) -> Validated(a),
) -> Validated(a) {
  let Validated(_prev_field, prev_errors, function) = validated
  let value = function()
  let length = string.length(value)
  let new_errors = case length >= min_length && length <= max_length {
    True -> []
    False -> [
      field_name
      <> " must be between "
      <> int.to_string(min_length)
      <> " and "
      <> int.to_string(max_length)
      <> " characters",
    ]
  }
  case new_errors {
    [] -> continue(value)
    _ -> {
      let Validated(next_field, next_errors, next_function) = continue(value)
      Validated(
        next_field,
        list.append(list.append(prev_errors, new_errors), next_errors),
        next_function,
      )
    }
  }
}

/// use構文対応：空でない文字列をチェック
pub fn non_empty_string(
  validated: Validated(String),
  field_name: String,
  continue: fn(String) -> Validated(a),
) -> Validated(a) {
  let Validated(_prev_field, prev_errors, function) = validated
  let value = function()
  let new_errors = case string.length(value) > 0 {
    True -> []
    False -> [field_name <> " cannot be empty"]
  }
  case new_errors {
    [] -> continue(value)
    _ -> {
      let Validated(next_field, next_errors, next_function) = continue(value)
      Validated(
        next_field,
        list.append(list.append(prev_errors, new_errors), next_errors),
        next_function,
      )
    }
  }
}

/// use構文対応：正の整数をチェック
pub fn positive_int(
  validated: Validated(Int),
  field_name: String,
  continue: fn(Int) -> Validated(a),
) -> Validated(a) {
  let Validated(_prev_field, prev_errors, function) = validated
  let value = function()
  let new_errors = case value > 0 {
    True -> []
    False -> [field_name <> " must be positive"]
  }
  case new_errors {
    [] -> continue(value)
    _ -> {
      let Validated(next_field, next_errors, next_function) = continue(value)
      Validated(
        next_field,
        list.append(list.append(prev_errors, new_errors), next_errors),
        next_function,
      )
    }
  }
}

/// use構文対応：整数の範囲をチェック
pub fn int_range(
  validated: Validated(Int),
  min_value: Int,
  max_value: Int,
  field_name: String,
  continue: fn(Int) -> Validated(a),
) -> Validated(a) {
  let Validated(_prev_field, prev_errors, function) = validated
  let value = function()
  let new_errors = case value >= min_value && value <= max_value {
    True -> []
    False -> [
      field_name
      <> " must be between "
      <> int.to_string(min_value)
      <> " and "
      <> int.to_string(max_value),
    ]
  }
  case new_errors {
    [] -> continue(value)
    _ -> {
      let Validated(next_field, next_errors, next_function) = continue(value)
      Validated(
        next_field,
        list.append(list.append(prev_errors, new_errors), next_errors),
        next_function,
      )
    }
  }
}

/// use構文対応：メールアドレスをチェック
pub fn email(
  validated: Validated(String),
  field_name: String,
  continue: fn(String) -> Validated(a),
) -> Validated(a) {
  let Validated(_prev_field, prev_errors, function) = validated
  let value = function()
  let new_errors = case
    string.contains(value, "@") && string.length(value) > 3
  {
    True -> []
    False -> [field_name <> " has invalid email address format"]
  }
  case new_errors {
    [] -> continue(value)
    _ -> {
      let Validated(next_field, next_errors, next_function) = continue(value)
      Validated(
        next_field,
        list.append(list.append(prev_errors, new_errors), next_errors),
        next_function,
      )
    }
  }
}
