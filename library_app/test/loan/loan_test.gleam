import gleam/json
import gleeunit
import gleeunit/should
import wisp/testing

import shell/adapters/web/router
import app/context

pub fn main() {
  gleeunit.main()
}

pub fn create_loan_success_test() {
  let body = json.object([#("book_id", "a" |> json.string)])
  let req = testing.post_json("/api/loans", [], body)
  let ctx = context.Context(
    ..context.new(),
    create_loan: fn(_) { Ok(Nil) },
  )
  let response = router.handle_request(req, ctx)

  response.status
  |> should.equal(201)
}
