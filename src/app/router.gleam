import app/adaptor/pages/ticket_detail_page
import gleam/http.{Get, Post}
import gleam/string_tree

import app/adaptor/api/ticket_controller
import app/adaptor/pages/ticket_page
import app/context
import app/features/person/person_controller
import app/web
import lib/http_core.{type Request, type Response}

pub fn handle_request(ctx: context.Context, req: Request) -> Response {
  use req <- web.middleware(req)

  case http_core.path_segments(req), req.method {
    [], Get -> home_page(req)
    ["tickets"], Get -> req |> ticket_page.get(ctx.ticket.listed) |> to_page()
    ["tickets", id], Get -> {
      ticket_detail_page.get(id, ctx.ticket.searched) |> to_page()
    }
    ["tickets"], Post -> {
      todo
    }
    ["api", ..path], method ->
      case path, method {
        ["persons"], _ -> person_controller.routes(req, ctx.person)
        ["tickets", ..path], _ ->
          ticket_controller.routes(path, req, ctx.ticket)
        _, _ -> http_core.not_found()
      }
    _, _ -> http_core.not_found()
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
