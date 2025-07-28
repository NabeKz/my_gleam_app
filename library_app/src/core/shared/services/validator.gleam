import gleam/int
import gleam/list
import gleam/option
import gleam/string

pub type Validator(t) {
  Validator(name: String, errors: List(ValidateError), function: fn() -> t)
}

pub type ValidateError {
  Required(field: String)
  LessThan(field: String, value: Int)
  GreaterThan(field: String, value: Int)
}

pub fn to_string(error: ValidateError) -> String {
  case error {
    Required(field) -> field <> " is " <> "required"
    LessThan(field, value) ->
      field <> " must be less than" <> int.to_string(value)
    GreaterThan(field, value) ->
      field <> " must be greater than" <> int.to_string(value)
  }
}

pub fn run(validator: Validator(t)) -> Result(t, List(ValidateError)) {
  case validator.errors {
    [] -> Ok(validator.function())
    _ -> Error(validator.errors)
  }
}

pub fn success(value: t) -> Validator(t) {
  Validator(name: "success", errors: [], function: fn() { value })
}

pub fn field(validator: Validator(a), f: fn(a) -> Validator(b)) -> Validator(b) {
  let value = validator.function()
  let result = f(value)
  let errors = [validator.errors, result.errors] |> list.flatten

  Validator(..result, errors:)
}

pub fn wrap(name: String, value: t) -> Validator(t) {
  let result = Validator(name:, errors: [], function: fn() { value })
  result
}

pub fn map(validator: Validator(a), f: fn(a) -> b) -> Validator(b) {
  Validator(..validator, function: fn() { validator.function() |> f })
}

pub fn required_string(validator: Validator(String)) -> Validator(String) {
  let result = validator.function()
  let size = result |> string.length
  case size > 0 {
    True -> validator
    False -> validator |> add_error(Required(validator.name))
  }
}

pub fn required_int(
  validator: Validator(option.Option(Int)),
) -> Validator(option.Option(Int)) {
  let result = validator.function()
  case result {
    option.Some(_) -> validator
    option.None -> validator |> add_error(Required(validator.name))
  }
}

pub fn less_than(validator: Validator(String), length: Int) -> Validator(String) {
  let size = validator.function() |> string.length
  case size < length {
    True -> validator
    _ -> validator |> add_error(LessThan(validator.name, length))
  }
}

pub fn greater_than(
  validator: Validator(String),
  length: Int,
) -> Validator(String) {
  let size = validator.function() |> string.length
  case size < length {
    True -> validator
    _ -> validator |> add_error(GreaterThan(validator.name, length))
  }
}

fn add_error(validator: Validator(t), error: ValidateError) -> Validator(t) {
  let errors = [error, ..validator.errors] |> list.reverse()
  Validator(..validator, errors:)
}
