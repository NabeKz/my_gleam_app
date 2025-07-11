import app/router
import gleam/json
import gleeunit
import gleeunit/should
import shared/context
import wisp/testing

pub fn main() {
  gleeunit.main()
}

pub fn loan_post_test() {
  let body = json.object([#("book_id", "a" |> json.string)])
  let req = testing.post_json("/api/loans", [], body)
  let ctx = context.new()
  let response = router.handle_request(req, ctx)

  response.status
  |> should.equal(200)
}
