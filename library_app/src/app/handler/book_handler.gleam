import gleam/json
import wisp

import features/book/usecase

pub fn get(_req: wisp.Request, query: usecase.SearchBooks) {
  "ok"
  |> json.string()
  |> json.to_string_tree()
  |> wisp.json_response(200)
}
