import gleam/json
import gleeunit
import gleeunit/should
import wisp/testing

import app/context
import app/person/person.{PersonReadModel, PersonRepository}
import app/router

fn mock_context() -> context.Context {
  context.Context(
    ..context.new(),
    person: PersonRepository(
      all: fn() {
        Ok([PersonReadModel(id: "hoge", name: "a", favorite_color: "FFF")])
      },
      save: fn(_) { Ok("1") },
      read: fn(_) { Error([]) },
      delete: fn(_) { Error([]) },
    ),
  )
}

pub fn main() {
  gleeunit.main()
}

pub fn get_persons_test() {
  let req = testing.get("/persons", [])
  let response = router.handle_request(mock_context(), req)

  response.status
  |> should.equal(200)

  response
  |> testing.string_body
  |> should.equal(
    "[{\"id\":\"hoge\",\"name\":\"a\",\"favorite_color\":\"FFF\"}]",
  )
}

pub fn submit_successful_test() {
  let object =
    json.object([
      #("name", json.string("name")),
      #("favorite-color", json.string("#FFF")),
    ])
  let response =
    testing.post_json("/persons", [], object)
    |> router.handle_request(mock_context(), _)

  response.status
  |> should.equal(201)
}
