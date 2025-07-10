import gleam/json
import wisp

import features/loan/domain

pub fn loan(req: wisp.Request) {
  use json <- wisp.require_json(req)

  let book_id = domain.parse_json(json)
  case book_id {
    Ok(_) -> {
      "ok"
      |> json.string()
      |> json.to_string_tree()
      |> wisp.json_response(200)
    }
    Error(_) -> {
      "ng" |> json.string() |> json.to_string_tree() |> wisp.json_response(400)
    }
  }
}

pub fn return_book(
  req: wisp.Request,
  return_book: domain.ReturnBook,
  book_id: String,
) {
  todo
}

pub fn get_loan(req: wisp.Request, get_loan: domain.GetLoan, book_id: String) {
  todo
}
