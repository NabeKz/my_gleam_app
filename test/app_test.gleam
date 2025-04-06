import gleeunit
import gleeunit/should
import wisp/testing

import app/router

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  let req = testing.get("/", [])
  let response = router.handle_request(req)

  response.status
  |> should.equal(200)

  response.headers
  |> should.equal([#("content-type", "text/html; charset=utf-8")])

  response
  |> testing.string_body
  |> should.equal("<h1>Hello, Joe!</h1>")
}
