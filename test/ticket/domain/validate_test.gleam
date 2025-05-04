import gleeunit
import gleeunit/should

import app/ticket/domain

pub fn main() {
  gleeunit.main()
}

pub fn validate_title_failure() {
  let object =
    json.object([
      #("title", json.string("hoge")),
      #("description", json.string("fugafuga")),
    ])

  let req = testing.post_json("/api/tickets", [], object)
  let response = router.handle_request(mock_context(), req)

  response.status
  |> should.equal(201)
}
