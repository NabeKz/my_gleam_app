import gleam/http.{Get}
import gleam/json
import wisp

pub fn handle_request(req: wisp.Request) -> wisp.Response {
  let path = wisp.path_segments(req)

  case path, req.method {
    ["health"], Get -> {
      json.string("ok")
      |> json.to_string()
      |> wisp.json_response(200)
    }
    _, _ -> wisp.not_found()
  }
}
