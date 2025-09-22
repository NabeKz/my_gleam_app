import gleam/http.{Get}
import wisp

pub fn handle_request(req: wisp.Request) -> wisp.Response {
  let path = wisp.path_segments(req)

  case path, req.method {
    ["health"], Get -> wisp.json_response("ok", 200)
    _, _ -> wisp.not_found()
  }
}
