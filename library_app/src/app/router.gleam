import gleam/http.{Get, Post}
import gleam/json
import wisp

import app/handler/book_handler
import app/handler/loan_handler
import shared/context

pub fn handle_request(req: wisp.Request, ctx: context.Context) -> wisp.Response {
  use path <- api_group("api", req)

  case path, req.method {
    ["books"], Get -> book_handler.get(req, ctx.search_books)
    ["loans"], Get -> loan_handler.get_loans(req, ctx.get_loans)
    ["loans", id], Get -> loan_handler.get_loan(id, ctx.get_loan)
    ["loans"], Post ->
      loan_handler.create_loan(req, ctx.current_date, ctx.create_loan_deps)
    ["health_check"], Get -> health_check()
    _, _ -> wisp.not_found()
  }
}

fn api_group(
  _group: String,
  req: wisp.Request,
  resp: fn(List(String)) -> wisp.Response,
) -> wisp.Response {
  case wisp.path_segments(req) {
    [_group, ..rest] -> rest
    _ -> []
  }
  |> resp()
}

fn health_check() {
  "ok"
  |> json.string
  |> json.to_string_tree
  |> wisp.json_response(200)
}
