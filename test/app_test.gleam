import gleam/json
import gleam/option
import gleeunit
import gleeunit/should
import wisp/testing

import app/context
import app/features/user/user.{UserReadModel, UserRepository}
import app/router

fn mock_context() -> context.Context {
  context.Context(
    ..context.new(),
    user: UserRepository(
      all: fn() {
        Ok([UserReadModel(id: "hoge", name: "a", favorite_color: "FFF")])
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

pub fn get_users_test() {
  let req = testing.get("/api/users", [])
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
    testing.post_json("/api/users", [], object)
    |> router.handle_request(mock_context(), _)

  response.status
  |> should.equal(201)
}
