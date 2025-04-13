import gleam/json
import gleeunit
import gleeunit/should
import wisp/testing

import app/context
import app/router
import app/ticket/infra/ticket_repository_on_memory
import app/ticket/ticket_controller
import app/ticket/usecase/ticket_listed.{Dto}

pub fn main() {
  gleeunit.main()
}

fn mock_context() -> context.Context {
  context.Context(
    ..context.new(),
    ticket: ticket_controller.Usecase(fn() {
      ticket_repository_on_memory.new().list
      |> ticket_listed.invoke
    }),
  )
}

pub fn get_tickets_test() {
  let req = testing.get("/tickets", [])
  let response = router.handle_request(mock_context(), req)
  let result =
    json.array(
      [
        Dto(id: "1", title: "hoge", status: "open"),
        Dto(id: "2", title: "fuga", status: "open"),
        Dto(id: "3", title: "piyo", status: "open"),
      ],
      fn(item) {
        json.object([
          #("id", json.string(item.id)),
          #("title", json.string(item.title)),
          #("status", json.string(item.status)),
        ])
      },
    )

  response.status
  |> should.equal(200)

  response
  |> testing.string_body
  |> should.equal(result |> json.to_string())
}

pub fn post_tickets_test() {
  let object =
    json.object([
      #("id", json.string("1")),
      #("id", json.string("1")),
      #("id", json.string("1")),
    ])

  let req = testing.post_json("/tickets", [], object)
  let response = router.handle_request(mock_context(), req)

  response.status
  |> should.equal(201)
}
