import gleam/bool
import gleam/http.{Get, Post}
import gleam/string_tree
import wisp

import app/adaptor/pages/ticket/detail_page
import app/adaptor/pages/ticket/list_page
import app/adaptor/pages/user/list_page as user_list_page
import app/context
import lib/http_core.{type Request, type Response}

pub fn handle_request(ctx: context.Context, req: Request) -> Response {
  use req <- middleware(req)

  case http_core.path_segments(req), req.method {
    [], Get -> home_page(req)
    ["users"], Get -> user_list_page.get(req) |> to_page()
    ["tickets"], Get -> req |> list_page.get(ctx.ticket.listed) |> to_page()
    ["tickets", id], Get -> {
      detail_page.get(id, ctx.ticket.searched) |> to_page()
    }
    ["tickets"], Post -> todo
    _, _ -> http_core.not_found()
  }
}

///
/// 
pub fn middleware(
  req: Request,
  handle_request: fn(Request) -> Response,
) -> Response {
  let req = http_core.method_override(req)
  // use <- wisp.log_request(req)
  // use <- wisp.rescue_crashes()
  use req <- http_core.handle_head(req)
  use <- default_responses()

  handle_request(req)
}

fn default_responses(handle_request: fn() -> Response) -> Response {
  let response = handle_request()

  use <- bool.guard(when: response.body != wisp.Empty, return: response)

  case response.status {
    404 | 405 ->
      "<h1>There's nothing here</h1>"
      |> string_tree.from_string()
      |> http_core.html_response(response.status)
    _ -> response
  }
}

fn home_page(_req: Request) -> Response {
  "
  <h1>Welcome!!</h1>
  <ul>
    <a href=/tickets> tickets </a>
  </ul>
  "
  |> to_page()
}

fn to_page(body: String) -> Response {
  body
  |> string_tree.from_string()
  |> http_core.html_response(200)
}
