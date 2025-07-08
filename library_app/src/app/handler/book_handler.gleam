import gleam/json
import wisp

import features/book/usecase

pub fn get(req: wisp.Request, search_books: usecase.SearchBooks) {
  let _ = search_books(req |> wisp.get_query)

  "ok"
  |> json.string()
  |> json.to_string_tree()
  |> wisp.json_response(200)
}
