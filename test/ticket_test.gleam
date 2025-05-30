import gleam/json
import gleeunit
import gleeunit/should
import wisp/testing

import app/adaptor/api/ticket_controller
import app/context
import app/features/ticket/infra/ticket_repository_on_memory
import app/features/ticket/usecase/ticket_created
import app/features/ticket/usecase/ticket_listed.{Dto}
import app/router

import ticket/fixture

pub fn main() {
  gleeunit.main()
}

fn mock_context() -> context.Context {
  let repository = ticket_repository_on_memory.new([])
  context.Context(
    ..context.mock(),
    ticket: ticket_controller.Resolver(
      ..fixture.ticket_resolver_mock(),
      listed: ticket_listed.invoke(_, repository.list),
      created: ticket_created.invoke(repository.create, _),
    ),
  )
}

pub fn get_tickets_test() {
  let req = testing.get("/api/tickets", [])
  let response = router.handle_request(mock_context(), req)
  let result =
    json.array(
      [
        Dto(id: "1", title: "hoge", status: "open", created_at: "2024-05-01"),
        Dto(id: "2", title: "fuga", status: "open", created_at: "2024-05-01"),
        Dto(id: "3", title: "piyo", status: "open", created_at: "2024-05-01"),
      ],
      fn(item) {
        json.object([
          #("id", json.string(item.id)),
          #("title", json.string(item.title)),
          #("status", json.string(item.status)),
          #("created_at", json.string(item.created_at)),
        ])
      },
    )

  response.status
  |> should.equal(200)

  response
  |> testing.string_body
  |> should.equal(result |> json.to_string())
}

pub fn post_tickets_success_test() {
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

pub fn post_tickets_failure_test() {
  let object =
    json.object([
      #("title1", json.string("hoge")),
      #("title2", json.string("hoge")),
    ])

  let req = testing.post_json("/api/tickets", [], object)
  let response = router.handle_request(mock_context(), req)

  response.status
  |> should.equal(400)
}
