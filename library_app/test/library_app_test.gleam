import app/router
import gleeunit
import gleeunit/should
import shared/context
import wisp/testing

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  let req = testing.get("/api/books?hoge=fuga&aaa=1", [])
  let ctx = context.new()
  let response = router.handle_request(req, ctx)

  response.status
  |> should.equal(200)
}
