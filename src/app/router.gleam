import app/context
import app/person/person_controller
import app/ticket/ticket_controller
import app/web
import gleam/http.{Get}
import gleam/string_tree
import lib/http_core.{type Request, type Response}

pub fn handle_request(ctx: context.Context, req: Request) -> Response {
  use req <- web.middleware(req)

  case http_core.path_segments(req), req.method {
    [], Get -> home_page(req)
    ["persons"], _ -> person_controller.routes(req, ctx.person)
    ["tickets", ..path], _ -> ticket_controller.routes(path, req, ctx.ticket)
    _, _ -> http_core.not_found()
  }
}

fn home_page(req: Request) -> Response {
  use <- http_core.require_method(req, Get)
  let html = string_tree.from_string("Hello, Joe!")

  http_core.ok()
  |> http_core.html_body(html)
}
