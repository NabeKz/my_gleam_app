import gleam/list
import gleeunit
import gleeunit/should

import order_processing/core/shared/validate

pub fn main() {
  gleeunit.main()
}

pub fn success_validation_test() {
  let result = validate.field("test", "valid_value", [])

  result
  |> validate.run()
  |> should.be_ok()
  |> should.equal("valid_value")
}

pub fn field_with_no_rules_test() {
  let result = validate.field("username", "john", [])

  result
  |> validate.run()
  |> should.be_ok()
  |> should.equal("john")
}

pub fn non_empty_valid_test() {
  let result = validate.field("username", "john", [validate.non_empty])

  result
  |> validate.run()
  |> should.be_ok()
  |> should.equal("john")
}

pub fn non_empty_invalid_test() {
  let result = validate.field("username", "", [validate.non_empty])

  case validate.run(result) {
    Ok(_) -> should.fail()
    Error(errors) -> {
      errors
      |> list.length()
      |> should.equal(1)

      let assert [error] = errors
      error
      |> should.equal(validate.Required("username"))
    }
  }
}

pub fn range_valid_test() {
  let result =
    validate.field("password", "password123", [validate.range(_, 8, 20)])

  result
  |> validate.run()
  |> should.be_ok()
  |> should.equal("password123")
}

pub fn range_too_short_test() {
  let result = validate.field("password", "123", [validate.range(_, 8, 20)])

  case validate.run(result) {
    Ok(_) -> should.fail()
    Error(errors) -> {
      errors
      |> list.length()
      |> should.equal(1)

      let assert [error] = errors
      error
      |> should.equal(validate.Length("password", 8, 20))
    }
  }
}

pub fn range_too_long_test() {
  let result =
    validate.field(
      "password",
      "this_is_a_very_long_password_that_exceeds_limit",
      [validate.range(_, 8, 20)],
    )

  case validate.run(result) {
    Ok(_) -> should.fail()
    Error(errors) -> {
      errors
      |> list.length()
      |> should.equal(1)

      let assert [error] = errors
      error
      |> should.equal(validate.Length("password", 8, 20))
    }
  }
}

pub fn multiple_rules_all_valid_test() {
  let result =
    validate.field("password", "password123", [
      validate.non_empty,
      validate.range(_, 8, 20),
    ])

  result
  |> validate.run()
  |> should.be_ok()
  |> should.equal("password123")
}

pub fn multiple_rules_first_fails_test() {
  let result =
    validate.field("password", "", [
      validate.non_empty,
      validate.range(_, 8, 20),
    ])

  case validate.run(result) {
    Ok(_) -> should.fail()
    Error(errors) -> {
      errors
      |> list.length()
      |> should.equal(2)

      let assert [first_error, second_error] = errors
      first_error
      |> should.equal(validate.Required("password"))
      second_error
      |> should.equal(validate.Length("password", 8, 20))
    }
  }
}

pub fn multiple_rules_second_fails_test() {
  let result =
    validate.field("password", "123", [
      validate.non_empty,
      validate.range(_, 8, 20),
    ])

  case validate.run(result) {
    Ok(_) -> should.fail()
    Error(errors) -> {
      errors
      |> list.length()
      |> should.equal(1)

      let assert [error] = errors
      error
      |> should.equal(validate.Length("password", 8, 20))
    }
  }
}

pub fn error_to_string_required_test() {
  let error = validate.Required("username")

  error
  |> validate.to_string()
  |> should.equal("username is required")
}

pub fn error_to_string_length_test() {
  let error = validate.Length("password", 8, 20)

  error
  |> validate.to_string()
  |> should.equal("password must be between 8 and 20")
}

pub fn error_to_string_less_than_test() {
  let error = validate.LessThan("age", 100)

  error
  |> validate.to_string()
  |> should.equal("age must be less than 100")
}

pub fn error_to_string_greater_than_test() {
  let error = validate.GreaterThan("age", 18)

  error
  |> validate.to_string()
  |> should.equal("age must be greater than 18")
}
