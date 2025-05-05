import gleam/int
import gleam/list
import gleam/string

pub type Validator(t) {
  Validator(name: String, errors: List(String), function: fn() -> t)
}

pub fn run(validator: Validator(t)) -> Result(t, List(String)) {
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
  let errors =
    validator.errors |> list.map(fn(error) { validator.name <> " " <> error })

  Validator(..result, errors: list.flatten([errors, result.errors]))
}

pub fn wrap(name: String, value: t) -> Validator(t) {
  let result = Validator(name:, errors: [], function: fn() { value })
  result
}

pub fn required(validator: Validator(String)) -> Validator(String) {
  let result = validator.function()
  let size = result |> string.length
  case size > 0 {
    True -> validator
    False -> validator |> add_error("required")
  }
}

pub fn less_than(validator: Validator(String), length: Int) -> Validator(String) {
  let size = validator.function() |> string.length
  case size < length {
    True -> validator
    _ -> validator |> add_error("must be less than " <> int.to_string(length))
  }
}

fn add_error(validator: Validator(t), error: String) -> Validator(t) {
  let errors = [error, ..validator.errors] |> list.reverse()
  Validator(..validator, errors:)
}
