import gleam/json
import gleeunit
import gleeunit/should
import wisp/testing

import app/router
import features/book/port/book_id
import features/loan/loan
import shared/context
import shared/date

pub fn main() {
  gleeunit.main()
}

pub fn create_loan_success_test() {
  let body = json.object([#("book_id", "a" |> json.string)])
  let req = testing.post_json("/api/loans", [], body)
  let ctx = context.new()
  let response = router.handle_request(req, ctx)

  response.status
  |> should.equal(201)
}

pub fn get_loans_success_test() {
  let params = "?hoge=1&fuga=a"
  let req = testing.get("/api/loans" <> params, [])
  let ctx =
    context.Context(..context.new(), get_loans: fn(_) {
      [
        loan.new(book_id.new(), date.from(#(2025, 7, 30))),
        loan.new(book_id.new(), date.from(#(2025, 8, 1))),
      ]
    })
  let response = router.handle_request(req, ctx)

  response.status
  |> should.equal(200)

  response
  |> testing.string_body
  |> should.equal("")
}
