import gleam/json
import gleeunit
import gleeunit/should
import wisp/testing

import app/router
import shared/context
import features/loan/service

pub fn main() {
  gleeunit.main()
}

pub fn create_loan_success_test() {
  let body = json.object([#("book_id", "a" |> json.string)])
  let req = testing.post_json("/api/loans", [], body)
  let ctx = context.Context(
    ..context.new(),
    create_loan_deps: service.CreateLoanDeps(
      ..context.new().create_loan_deps,
      save_loan: fn(_) { Ok(Nil) },
    ),
  )
  let response = router.handle_request(req, ctx)

  response.status
  |> should.equal(201)
}
