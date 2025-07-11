import gleam/dynamic/decode

import gleam/json
import wisp

pub fn ok(body: json.Json) -> wisp.Response {
  body
  |> json.to_string_tree()
  |> wisp.json_response(200)
}

pub fn bad_request(body: json.Json) -> wisp.Response {
  body
  |> json.to_string_tree()
  |> wisp.json_response(400)
}

pub fn require_json(
  req: wisp.Request,
  decoder: decode.Decoder(t),
  next: fn(t) -> wisp.Response,
) -> wisp.Response {
  use <- wisp.require_content_type(req, "application/json")
  use body <- wisp.require_string_body(req)
  case json.parse(body, decoder) {
    Ok(json) -> next(json)
    Error(_) -> wisp.bad_request()
  }
}
