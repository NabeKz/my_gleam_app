import gleam/json
import wisp

import features/book/converter
import features/book/domain

fn thunk(f: a) -> fn() -> a {
  fn() { f }
}

pub fn get(req: wisp.Request, search_books: domain.SearchBooks) {
  let result =
    req
    |> wisp.get_query()
    |> converter.to_search_params()
    |> thunk()
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
