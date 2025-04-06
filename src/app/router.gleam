import gleam/string_tree
import wisp.{type Request, type Response}

import app/web

pub fn handle_request(req: Request) -> Response {
  use _req <- web.middleware(req)
  let body = string_tree.from_string("<h1>Hello, Joe!</h1>")

  wisp.html_response(body, 200)
}
