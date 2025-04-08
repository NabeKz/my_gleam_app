import app/web
import app/web/person
import gleam/http.{Get, Post}
import gleam/string_tree
import wisp.{type Request, type Response}

pub fn handle_request(ctx: person.Context, req: Request) -> Response {
  use _res <- web.middleware(req)

  case wisp.path_segments(req), req.method {
    [], Get -> home_page(req)
    ["comments"], Get -> list_comments()
    ["comments"], Post -> create_comment(req)
    ["comments", id], Get -> show_comment(req, id)
    ["persons"], _ -> person.person_controller(req, ctx)
    _, _ -> wisp.not_found()
  }
}

fn home_page(req: Request) -> Response {
  use <- wisp.require_method(req, Get)
  let html = string_tree.from_string("Hello, Joe!")

  wisp.ok()
  |> wisp.html_body(html)
}

fn list_comments() -> Response {
  let html = string_tree.from_string("Comments!")

  wisp.ok()
  |> wisp.html_body(html)
}

fn create_comment(_req: Request) -> Response {
  let html = string_tree.from_string("Created")

  wisp.ok()
  |> wisp.html_body(html)
}

fn show_comment(req: Request, id: String) -> Response {
  use <- wisp.require_method(req, Get)
  let html = string_tree.from_string("Comment with id " <> id)

  wisp.ok()
  |> wisp.html_body(html)
}
