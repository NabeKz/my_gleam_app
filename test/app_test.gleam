import app/web/person
import gleam/json
import gleeunit
import gleeunit/should
import wisp/testing

import app/router

fn mock_repository() {
  person.PersonRepository(
    all: fn() { todo },
    save: fn(_) { Ok("id") },
    read: fn(_) { todo },
    delete: fn(_) { todo },
  )
}

pub fn main() {
  gleeunit.main()
}

pub fn get_comments_test() {
  let req = testing.get("/comments", [])
  let response = router.handle_request(mock_repository(), req)

  response.status
  |> should.equal(200)

  response
  |> testing.string_body
  |> should.equal("Comments!")
}

pub fn submit_successful_test() {
  let object =
    json.object([
      #("name", json.string("name")),
      #("favorite-color", json.string("#FFF")),
    ])
  let response =
    testing.post_json("/persons", [], object)
    |> router.handle_request(mock_repository(), _)

  response.status
  |> should.equal(201)
}
