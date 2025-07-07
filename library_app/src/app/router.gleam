import gleam/http.{Get}
import gleam/json
import wisp

import app/handler/book_handler
import shared/context

pub fn handle_request(_ctx: context.Context, req: wisp.Request) -> wisp.Response {
  use path <- api_group(req)

  case path, req.method {
    ["books"], _ -> book_handler.get(req)
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
