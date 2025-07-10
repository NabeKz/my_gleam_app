import gleam/json
import gleam/result
import shared/date
import wisp

import features/loan/domain

pub fn loan(
  req: wisp.Request,
  create_book: domain.CreateLoan,
  current_date: date.Date,
) {
  use json <- wisp.require_json(req)

  let result = {
    use book_id <- result.map(domain.parse_json(json))
    book_id |> create_book(current_date)
  }
  case result {
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
