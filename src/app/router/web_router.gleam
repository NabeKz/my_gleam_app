import gleam/bool
import gleam/http.{Get, Post}
import gleam/string_tree
import wisp

import app/adaptor/pages/ticket
import app/adaptor/pages/user/list_page as user_list_page
import app/context
import lib/http_core.{type Request, type Response}

pub fn handle_request(ctx: context.Context, req: Request) -> Response {
  use req <- middleware(req)

  case http_core.path_segments(req), req.method {
    [], Get -> home_page(req)
    ["users"], Get -> user_list_page.get(req, ctx.user.listed)
    ["tickets"], Get -> req |> ticket.list_page(ctx.ticket.listed)
    ["tickets", "create"], Get -> req |> ticket.create_page()
    ["tickets", "create"], Post ->
      req |> ticket.create_result_page(ctx.ticket.created)
    ["tickets", id], Get -> ticket.detail_page(id, ctx.ticket.searched)
    ["tickets", id, "update"], Get ->
      ticket.detail_page(id, ctx.ticket.searched)
    // TODO: method override
    ["tickets", id], Post -> ticket.delete_page(id, ctx.ticket.deleted)
    _, _ -> ""
  }
}

///
/// 
pub fn middleware(
  req: Request,
  handle_request: fn(Request) -> String,
) -> Response {
  let req = http_core.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes()
  use req <- http_core.handle_head(req)
  use <- default_responses()
  use req <- to_page(req)

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

fn home_page(_req: Request) -> String {
  "
  <h1>Welcome!!</h1>
  <ul>
    <li>
      <a href=/users> users </a>
    </li>
    <li>
      <a href=/tickets> tickets </a>
    </li>
  </ul>
  "
}

fn to_page(req: Request, handle_request: fn(Request) -> String) -> Response {
  let res = handle_request(req)

  case res {
    "" -> http_core.not_found()
    _ ->
      res
      |> string_tree.from_string()
      |> http_core.html_response(200)
  }
}
