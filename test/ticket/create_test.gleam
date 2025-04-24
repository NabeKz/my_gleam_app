import gleam/json
import gleeunit
import gleeunit/should
import wisp/testing

import app/context
import app/router
import app/ticket/infra/ticket_repository_on_memory
import app/ticket/ticket_controller
import app/ticket/usecase/ticket_created

pub fn main() {
  gleeunit.main()
}

fn mock_context() -> context.Context {
  let repository = ticket_repository_on_memory.new([])
  context.Context(
    ..context.new(),
    ticket: ticket_controller.Resolver(
      listed: fn(_) { Error([]) },
      created: ticket_created.invoke(repository.create, _),
      searched: fn(_) { Error([]) },
      deleted: fn(_) { Error([]) },
    ),
  )
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
