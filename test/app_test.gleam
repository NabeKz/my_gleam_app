import gleam/json
import gleeunit
import gleeunit/should
import wisp/testing

import app/router

pub fn main() {
  gleeunit.main()
}

pub fn get_home_page_test() {
  let req = testing.get("/", [])
  let response = router.handle_request(req)

  response.status
  |> should.equal(200)

  response.headers
  |> should.equal([#("content-type", "text/html; charset=utf-8")])

  response
  |> testing.string_body
  |> should.equal("Hello, Joe!")
}

pub fn page_not_found_test() {
  let req = testing.post("/", [], "a body")
  let response = router.handle_request(req)

  response.status
  |> should.equal(404)
}

pub fn get_comments_test() {
  let req = testing.get("/comments", [])
  let response = router.handle_request(req)

  response.status
  |> should.equal(200)

  response
  |> testing.string_body
  |> should.equal("Comments!")
}

pub fn submit_wrong_content_type_test() {
  let response =
    testing.post("/persons", [], "")
    |> router.handle_request()

  response.status
  |> should.equal(415)
}

pub fn submit_missing_parameters_test() {
  let object = json.object([#("name", json.string("name"))])
  let response =
    testing.post_json("/persons", [], object)
    |> router.handle_request()

  response.status
  |> should.equal(422)
}

pub fn submit_successful_test() {
  let object =
    json.object([#("name", json.string("name")), #("is_cool", json.bool(True))])
  let response =
    testing.post_json("/persons", [], object)
    |> router.handle_request()

  response.status
  |> should.equal(200)
}
