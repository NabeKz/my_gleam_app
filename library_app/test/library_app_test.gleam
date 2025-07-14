import shell/adapters/web/router
import gleeunit
import gleeunit/should
import app/context
import wisp/testing

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn books_optional_query_test() {
  let req = testing.get("/api/books?hoge=fuga&aaa=1", [])
  let ctx = context.new()
  let response = router.handle_request(req, ctx)

  response.status
  |> should.equal(200)
}
