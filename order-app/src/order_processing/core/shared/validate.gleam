import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Validated(t) {
  Validated(name: String, errors: List(ValidateError), function: fn() -> t)
}

pub type ValidateError {
  Required(field: String)
  Length(field: String, min: Int, max: Int)
  LessThan(field: String, value: Int)
  GreaterThan(field: String, value: Int)
}

/// rules
pub fn non_empty(validator: Validated(String)) -> Validated(String) {
  let result = validator.function()
  let size = result |> string.length
  case size > 0 {
    True -> validator
    False -> validator |> add_error(Required(validator.name))
  }
}

pub fn range(
  validator: Validated(String),
  min: Int,
  max: Int,
) -> Validated(String) {
  let length = validator.function() |> string.length
  let cond = length >= min && length <= max

  case cond {
    True -> validator
    False -> validator |> add_error(Length(validator.name, min, max))
  }
}

pub fn min(validator: Validated(Int), min_val: Int) -> Validated(Int) {
  let value = validator.function()
  case value >= min_val {
    True -> validator
    False -> validator |> add_error(GreaterThan(validator.name, min_val - 1))
  }
}

pub fn max(validator: Validated(Int), max_val: Int) -> Validated(Int) {
  let value = validator.function()
  case value <= max_val {
    True -> validator
    False -> validator |> add_error(LessThan(validator.name, max_val + 1))
  }
}

/// utils
pub fn to_string(error: ValidateError) -> String {
  case error {
    Required(field) -> field <> " is " <> "required"
    Length(field, min, max) -> {
      let #(min, max) = #(int.to_string(min), int.to_string(max))
      field <> " must be between " <> min <> " and " <> max
    }
    LessThan(field, value) ->
      field <> " must be less than " <> int.to_string(value)
    GreaterThan(field, value) ->
      field <> " must be greater than " <> int.to_string(value)
  }
}

pub fn run(validated: Validated(t)) -> Result(t, List(ValidateError)) {
  case validated.errors {
    [] -> validated.function() |> Ok()
    _ -> validated.errors |> Error()
  }
}

pub fn success(
  value: Result(a, List(ValidateError)),
  f: fn(a) -> b,
) -> Result(b, List(ValidateError)) {
  result.map(value, f)
}

pub fn field(
  name: String,
  value: a,
  rules: List(fn(Validated(a)) -> Validated(a)),
) -> Validated(a) {
  let validated = Validated(name:, errors: [], function: fn() { value })
  let validated = list.fold(rules, validated, fn(acc, cur) { cur(acc) })
  validated
}

pub fn field2(name: String, value: a) -> Validated(a) {
  Validated(name:, errors: [], function: fn() { value })
}

pub fn field3(validator: Validated(a), f: fn(a) -> Validated(b)) -> Validated(b) {
  let value = validator.function()
  let result = f(value)
  let errors = [validator.errors, result.errors] |> list.flatten

  Validated(..result, errors:)
}

pub fn record(value: a) -> Validated(a) {
  Validated(name: "success", errors: [], function: fn() { value })
}

/// Result型をValidated型に変換
pub fn from_result(
  name: String,
  result: Result(a, List(ValidateError)),
) -> Validated(a) {
  case result {
    Ok(value) -> record(value)
    Error(errors) -> Validated(name:, errors:, function: fn() { panic })
  }
}

fn add_error(validator: Validated(t), error: ValidateError) -> Validated(t) {
  let errors = list.append(validator.errors, [error])
  Validated(..validator, errors:)
}

pub fn chain_result(
  result: Result(a, List(ValidateError)),
  name: String,
  f: fn(a) -> Validated(b),
) -> Validated(b) {
  case result {
    Ok(value) -> f(value)
    Error(errors) -> Validated(name, errors, fn() { panic })
  }
}
