import gleam/int
import gleam/list
import gleam/string

pub type Validator(t) {
  Validator(value: t, errors: List(String))
}

pub type Rule(t) =
  fn(Validator(t)) -> Validator(t)

pub fn validate(
  value: a,
  validator: fn(a) -> Result(a, String),
  next: next,
) -> Result(a, String) {
  todo
}

pub fn run(value: t) -> Validator(t) {
  Validator(value:, errors: [])
}

fn add_error(validator: Validator(t), error: String) -> Validator(t) {
  let errors = [error, ..validator.errors] |> list.reverse()
  Validator(..validator, errors:)
}

pub fn required(validator: Validator(String)) -> Validator(String) {
  let size = validator.value |> string.length
  case size > 0 {
    True -> validator
    False -> validator |> add_error("required")
  }
}

pub fn less_than(validator: Validator(String), length: Int) -> Validator(String) {
  let size = validator.value |> string.length
  case size < length {
    True -> validator
    _ -> validator |> add_error("should less than " <> int.to_string(length))
  }
}
