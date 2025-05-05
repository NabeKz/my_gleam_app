import gleam/int
import gleam/list
import gleam/string

pub type Validator(t) {
  Validator(name: String, value: t, errors: List(String))
}

pub type Workflow(t) {
  Workflow(validators: List(Validator(t)))
}

pub type Rule(t) =
  fn(Validator(t)) -> Validator(t)

pub fn validate(
  value: List(Validator(t)),
  f: fn() -> a,
) -> Result(a, List(String)) {
  let errors =
    list.fold(value, [], fn(a, b) {
      let errors = list.map(b.errors, fn(error) { b.name <> " " <> error })
      list.append(a, errors)
    })
  case errors {
    [] -> Ok(f())
    _ -> Error(errors)
  }
}

pub fn run(result: Validator(a)) -> Result(a, List(String)) {
  case result.errors {
    [] -> Ok(result.value)
    _ -> Error(result.errors)
  }
}

pub fn success(value: t) -> Validator(t) {
  Validator(name: "success", value:, errors: [])
}

pub fn wrap(name: String, value: t) -> Validator(t) {
  let result = Validator(name:, value:, errors: [])
  result
}

pub fn field(validator: Validator(a), f: fn(a) -> Validator(b)) -> Validator(b) {
  let value = validator.value
  let result = f(value)
  let errors =
    validator.errors |> list.map(fn(error) { validator.name <> " " <> error })

  Validator(..result, errors: list.flatten([errors, result.errors]))
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
    _ -> validator |> add_error("must be less than " <> int.to_string(length))
  }
}
