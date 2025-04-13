import app/context
import app/person/person_controller
import app/ticket/ticket_controller
import app/web
import gleam/http.{Get}
import gleam/string_tree
import wisp.{type Request, type Response}

pub fn handle_request(ctx: context.Context, req: Request) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req), req.method {
    [], Get -> home_page(req)
    ["persons"], _ -> person_controller.routes(req, ctx.person)
    ["tickets", ..path], _ -> ticket_controller.routes(path, req, ctx.ticket)
    _, _ -> wisp.not_found()
  }
}

fn home_page(req: Request) -> Response {
  use <- wisp.require_method(req, Get)
  let html = string_tree.from_string("Hello, Joe!")

  wisp.ok()
  |> wisp.html_body(html)
}
