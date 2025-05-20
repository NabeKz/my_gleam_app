import gleeunit
import gleeunit/should
import wisp/testing

import app/adaptor/api/ticket_controller
import app/context
import app/features/ticket/usecase/ticket_listed
import app/router

import ticket/fixture

pub fn main() {
  gleeunit.main()
}

fn mock_context() -> context.Context {
  context.Context(
    ..context.mock(),
    ticket: ticket_controller.Resolver(
      ..fixture.ticket_resolver_mock(),
      listed: ticket_listed.invoke(_, fn(_) { [] }),
    ),
  )
}

pub fn get_ticket_success_test() {
  let req = testing.get("/api/tickets?status=close", [])
  let response = router.handle_request(mock_context(), req)

  response.status
  |> should.equal(200)
}

pub fn get_ticket_not_exist_status_test() {
  let req = testing.get("/api/tickets?status=progress", [])
  let response = router.handle_request(mock_context(), req)

  response.status
  |> should.equal(200)
}

pub fn get_ticket_with_invalid_status_test() {
  let req = testing.get("/api/tickets?status=hoge", [])
  let response = router.handle_request(mock_context(), req)

  response.status
  |> should.equal(400)
}
