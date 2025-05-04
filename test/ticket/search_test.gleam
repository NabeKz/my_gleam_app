import app/ticket/domain
import gleam/json
import gleeunit
import gleeunit/should
import wisp/testing

import app/context
import app/router
import app/ticket/infra/ticket_repository_on_memory
import app/ticket/ticket_controller
import app/ticket/usecase/ticket_searched

pub fn main() {
  gleeunit.main()
}

fn mock_context() -> context.Context {
  let repository =
    ticket_repository_on_memory.new([
      domain.new_ticket(
        id: "1",
        title: "a",
        description: "",
        created_at: "2025-05-01",
      ),
    ])
  context.Context(
    ..context.new(),
    ticket: ticket_controller.Resolver(
      listed: fn(_) { Error([]) },
      created: fn(_) { Error([]) },
      searched: ticket_searched.invoke(_, repository.find),
      deleted: fn(_) { Error([]) },
    ),
  )
}

pub fn get_ticket_success_test() {
  let req = testing.get("/api/tickets/1", [])
  let response = router.handle_request(mock_context(), req)
  let result =
    json.object([
      #("id", json.string("1")),
      #("title", json.string("a")),
      #("description", json.string("")),
      #("status", json.string("open")),
      #("created_at", json.string("2025-05-01")),
    ])

  response.status
  |> should.equal(200)

  response
  |> testing.string_body
  |> should.equal(result |> json.to_string())
}

pub fn get_ticket_failure_test() {
  let req = testing.get("/api/tickets/2", [])
  let response = router.handle_request(mock_context(), req)

  response.status
  |> should.equal(400)
}
