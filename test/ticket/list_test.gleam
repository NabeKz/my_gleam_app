import gleam/json
import gleam/option.{None}
import gleeunit
import gleeunit/should
import wisp/testing

import app/context
import app/router
import app/ticket/domain
import app/ticket/infra/ticket_repository_on_memory
import app/ticket/ticket_controller
import app/ticket/usecase/ticket_listed.{Dto}

pub fn main() {
  gleeunit.main()
}

fn mock_context() -> context.Context {
  let repository = ticket_repository_on_memory.new([])
  context.Context(
    ..context.new(),
    ticket: ticket_controller.Resolver(
      created: fn(_) { Error([]) },
      searched: fn(_) { Error([]) },
      deleted: fn(_) { Error([]) },
      listed: ticket_listed.invoke(_, fn(_) {
        [
          domain.new_ticket(id: "1", title: "hoge", created_at: "2024-05-01"),
          domain.new_ticket(id: "2", title: "fuga", created_at: "2024-05-02"),
          domain.new_ticket(id: "3", title: "piyo", created_at: "2024-05-03"),
        ]
      }),
    ),
  )
}

pub fn get_ticket_success_test() {
  let req = testing.get("/tickets?hoge=1", [])
  let response = router.handle_request(mock_context(), req)
  let result =
    [
      json.object([
        #("id", json.string("1")),
        #("title", json.string("hoge")),
        #("status", json.string("open")),
        #("created_at", json.string("2024-05-01")),
      ]),
      json.object([
        #("id", json.string("2")),
        #("title", json.string("fuga")),
        #("status", json.string("open")),
        #("created_at", json.string("2024-05-02")),
      ]),
      json.object([
        #("id", json.string("3")),
        #("title", json.string("piyo")),
        #("status", json.string("open")),
        #("created_at", json.string("2024-05-03")),
      ]),
    ]
    |> json.array(fn(it) { it })

  response.status
  |> should.equal(200)

  response
  |> testing.string_body
  |> should.equal(result |> json.to_string())
}

pub fn get_ticket_failure_test() {
  let req = testing.get("/tickets?created_at=1", [])
  let response = router.handle_request(mock_context(), req)

  response.status
  |> should.equal(400)
}
