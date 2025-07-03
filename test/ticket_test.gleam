import gleam/json
import gleeunit
import gleeunit/should
import wisp/testing

import app/adaptor/api/ticket_controller
import app/context
import app/features/ticket/infra/ticket_repository_on_memory
import app/features/ticket/usecase/ticket_created
import app/features/ticket/usecase/ticket_listed
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
