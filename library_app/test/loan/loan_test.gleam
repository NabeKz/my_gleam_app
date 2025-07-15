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
        loan.new(book.id, date.from(#(2025, 7, 31))),
        loan.new(book.id, date.from(#(2025, 8, 1))),
        loan.new(book.id, date.from(#(2025, 8, 30))),
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
  let body = json.object([#("book_id", "a" |> json.string)])
  let req = testing.post_json("/api/loans", [], body)
  let assert Ok(book) = book.new("a", "b")
  let ctx =
    context.Context(
      ..context.new(),
      create_loan: loan_command.create_loan_workflow(
        _,
        fn() { date.from(#(2025, 7, 31)) },
        fn(_) { Ok(book.id) },
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
  let body = json.object([#("book_id", "a" |> json.string)])
  let req = testing.post_json("/api/loans", [], body)
  let ctx =
    context.Context(
      ..context.new(),
      create_loan: loan_command.create_loan_workflow(
        _,
        fn() { date.from(#(2025, 7, 31)) },
        fn(_) { Error("not found") },
        fn(_) { Ok(Nil) },
      ),
    )
  let response = router.handle_request(req, ctx)

  response.status
  |> should.equal(400)

  response
  |> testing.string_body()
  |> should.equal("not found")
}
