import gleam/json
import gleeunit
import gleeunit/should
import wisp/testing

import app/context
import app/router
import app/ticket/domain
import app/ticket/domain/ticket_status
import app/ticket/ticket_controller
import app/ticket/usecase/ticket_listed

pub fn main() {
  gleeunit.main()
}

fn mock_context() -> context.Context {
  context.Context(
    ..context.new(),
    ticket: ticket_controller.Resolver(
      created: fn(_) { Error([]) },
      searched: fn(_) { Error([]) },
      deleted: fn(_) { Error([]) },
      listed: ticket_listed.invoke(_, fn(_) {
        [
          domain.Ticket(
            id: domain.ticket_id("1"),
            title: "hoge",
            description: "",
            status: ticket_status.Open,
            created_at: "2024-05-01",
            replies: [],
          ),
          domain.Ticket(
            id: domain.ticket_id("2"),
            title: "fuga",
            description: "",
            status: ticket_status.Close,
            created_at: "2024-05-02",
            replies: [],
          ),
          domain.Ticket(
            id: domain.ticket_id("3"),
            title: "piyo",
            description: "",
            status: ticket_status.Done,
            created_at: "2024-05-03",
            replies: [],
          ),
        ]
      }),
    ),
  )
}

pub fn get_ticket_success_test() {
  let req = testing.get("/api/tickets?status=close", [])
  let response = router.handle_request(mock_context(), req)
  let result =
    [
      json.object([
        #("id", json.string("2")),
        #("title", json.string("fuga")),
        #("status", json.string("close")),
        #("created_at", json.string("2024-05-02")),
      ]),
    ]
    |> json.array(fn(it) { it })

  response.status
  |> should.equal(200)

  response
  |> testing.string_body
  |> should.equal(result |> json.to_string())
}

pub fn get_ticket_not_exist_status_test() {
  let req = testing.get("/api/tickets?status=progress", [])
  let response = router.handle_request(mock_context(), req)

  let result = [] |> json.array(fn(it) { it })

  response.status
  |> should.equal(200)

  response
  |> testing.string_body
  |> should.equal(result |> json.to_string())
}

pub fn get_ticket_with_invalid_status_test() {
  let req = testing.get("/api/tickets?status=hoge", [])
  let response = router.handle_request(mock_context(), req)

  let result =
    [json.object([#("message", json.string("hoge is invalid status"))])]
    |> json.array(fn(it) { it })

  response.status
  |> should.equal(400)

  response
  |> testing.string_body
  |> should.equal(result |> json.to_string())
}
