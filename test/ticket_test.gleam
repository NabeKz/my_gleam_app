import gleam/json
import gleeunit
import gleeunit/should
import wisp/testing

import app/context
import app/router
import app/ticket/infra/ticket_repository_on_memory
import app/ticket/ticket_controller
import app/ticket/usecase/ticket_created
import app/ticket/usecase/ticket_listed.{Dto}
import app/ticket/usecase/ticket_searched

pub fn main() {
  gleeunit.main()
}

fn mock_context() -> context.Context {
  let repository = ticket_repository_on_memory.new([])
  context.Context(
    ..context.new(),
    ticket: ticket_controller.Resolver(
      listed: ticket_listed.invoke(repository.list, _),
      created: ticket_created.invoke(repository.create, _),
      searched: ticket_searched.invoke(_, repository.find),
    ),
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

pub fn post_tickets_success_test() {
  let object =
    json.object([
      #("title", json.string("hoge")),
      #("description", json.string("fugafuga")),
    ])

  let req = testing.post_json("/tickets", [], object)
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

  let req = testing.post_json("/tickets", [], object)
  let response = router.handle_request(mock_context(), req)

  response.status
  |> should.equal(400)
}
