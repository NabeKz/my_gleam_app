import gleam/bool
import gleam/string_tree
import lib/http_core.{type Request, type Response}
import wisp

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
      |> http_core.html_body(response, _)
    _ -> response
  }
}
