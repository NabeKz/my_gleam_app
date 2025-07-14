import gleam/json
import wisp

import core/book/services/converter
import core/book/types/book as domain

pub fn get(req: wisp.Request, search_books: domain.SearchBooks) {
  let result =
    req
    |> wisp.get_query()
    |> converter.to_search_params()
    |> search_books()

  case result {
    Ok(_) -> {
      "ok"
      |> json.string()
      |> json.to_string_tree()
      |> wisp.json_response(200)
    }
    Error(_) -> {
      "error"
      |> json.string()
      |> json.to_string_tree()
      |> wisp.json_response(400)
    }
  }
}
