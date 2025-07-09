import gleam/http.{Get, Post, Delete}
import gleam/json
import wisp

import app/handler/book_handler
import app/handler/loan_handler
import shared/context

pub fn handle_request(req: wisp.Request, ctx: context.Context) -> wisp.Response {
  use path <- api_group(req)

  case path, req.method {
    ["books"], Get -> book_handler.get(req, ctx.search_books)
    ["loans", book_id], Post -> loan_handler.loan(req, ctx.loan_book, book_id, "2024-12-31") // TODO: due_dateをリクエストから取得
    ["loans", book_id], Delete -> loan_handler.return_book(req, ctx.return_book, book_id)
    ["loans", book_id], Get -> loan_handler.get_loan(req, ctx.get_loan, book_id)
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
