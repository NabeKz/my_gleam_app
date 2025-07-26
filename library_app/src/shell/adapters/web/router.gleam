import gleam/http.{Get, Post, Put}
import gleam/json
import wisp

import app/context
import shell/adapters/web/handler/book_handler
import shell/adapters/web/handler/loan_handler

pub fn handle_request(req: wisp.Request, ctx: context.Context) -> wisp.Response {
  use path <- api_group(req)

  case path, req.method {
    ["books"], Get -> book_handler.get(req, ctx.search_books)
    ["books"], Post -> book_handler.post(req, ctx.create_book)
    ["books", book_id, "loans"], Post ->
      loan_handler.create_loan(req, ctx, book_id)
    ["loans", book_id], Put ->
      loan_handler.update_loan_by_return_book(book_id, ctx)
    ["loans"], Get -> loan_handler.get_loans(req, ctx.get_loans)
    ["loans", id], Get -> loan_handler.get_loan(id, ctx.get_loan)
    ["health_check"], Get -> health_check()
    _, _ -> wisp.not_found()
  }
}

fn api_group(
  req: wisp.Request,
  resp: fn(List(String)) -> wisp.Response,
) -> wisp.Response {
  case wisp.path_segments(req) {
    ["api", ..rest] -> rest
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
