import core/auth/auth_provider
import core/shared/types/user
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleeunit
import gleeunit/should
import wisp/testing

import app/context
import core/book/book
import core/loan/loan
import core/loan/loan_command
import core/shared/types/date
import shell/adapters/web/router

pub fn main() {
  gleeunit.main()
}

pub fn get_loans_success_test() {
  let req = testing.get("/api/loans?hoge=1", [])
  let assert Ok(book) = book.new("a", "b")
  let ctx =
    context.Context(..context.new(), get_loans: fn(_) {
      [
        loan.new(book.id, user.id_from_string("1"), date.from(#(2025, 7, 31))),
        loan.new(book.id, user.id_from_string("2"), date.from(#(2025, 8, 1))),
        loan.new(book.id, user.id_from_string("3"), date.from(#(2025, 8, 30))),
      ]
    })
  let response = router.handle_request(req, ctx)

  response.status
  |> should.equal(200)

  let assert Ok(response) =
    response
    |> testing.string_body()
    |> json.parse(decode.list(decode.dynamic))

  response
  |> list.length()
  |> should.equal(3)
}

pub fn create_loan_success_test() {
  let req =
    testing.post_json(
      "/api/books/a/loans",
      [#("authorization", "dummy")],
      json.object([]),
    )
  let assert Ok(book) = book.new("a", "b")
  let ctx =
    context.Context(
      ..context.new(),
      authenticated: auth_provider.on_mock(),
      create_loan: loan_command.create_loan_workflow(
        fn() { date.from(#(2025, 7, 31)) },
        fn(_) { Ok(book.id) },
        fn(_) { [] },
        fn(_) { Ok(Nil) },
      ),
    )
  let response = router.handle_request(req, ctx)

  response.status
  |> should.equal(201)

  response
  |> testing.string_body()
  |> should.equal("")
}

pub fn create_loan_failure_test() {
  let req =
    testing.post_json(
      "/api/books/a/loans",
      [#("authorization", "dummy")],
      json.object([]),
    )
  let ctx =
    context.Context(
      ..context.new(),
      create_loan: loan_command.create_loan_workflow(
        fn() { date.from(#(2025, 7, 31)) },
        fn(_) { Error("not found") },
        fn(_) { [] },
        fn(_) { Ok(Nil) },
      ),
    )
  let response = router.handle_request(req, ctx)

  response.status
  |> should.equal(400)

  response
  |> testing.string_body()
  |> should.equal("\"not found\"")
}

pub fn has_overdue_false_test() {
  let loan_date = date.from(#(2025, 7, 1))
  let current_date = date.from(#(2025, 7, 15))
  let loan =
    loan.new(book.id_from_string("1"), user.id_from_string("a"), loan_date)

  loan.has_overdue([loan], current_date)
  |> should.be_false()
}

pub fn has_overdue_true_test() {
  let loan_date = date.from(#(2025, 7, 1))
  let current_date = date.from(#(2025, 7, 16))
  let loan =
    loan.new(book.id_from_string("1"), user.id_from_string("a"), loan_date)

  loan.has_overdue([loan], current_date)
  |> should.be_true()
}

pub fn is_loan_limit_true_test() {
  let expect =
    list.repeat(
      loan.new(
        book.id_from_string("1"),
        user.id_from_string("a"),
        date.from(#(2025, 7, 16)),
      ),
      10,
    )

  expect
  |> loan.is_loan_limit()
  |> should.be_true()
}

pub fn is_loan_limit_false_test() {
  let expect =
    list.repeat(
      loan.new(
        book.id_from_string("1"),
        user.id_from_string("a"),
        date.from(#(2025, 7, 16)),
      ),
      9,
    )

  expect
  |> loan.is_loan_limit()
  |> should.be_false()
}
