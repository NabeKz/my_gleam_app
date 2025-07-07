import gleam/json
import wisp

pub fn get(_req: wisp.Request) {
  "ok"
  |> json.string()
  |> json.to_string_tree()
  |> wisp.json_response(200)
}
