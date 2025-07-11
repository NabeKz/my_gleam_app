import gleam/json
import wisp

import app/handler/json_response
import features/loan/domain
import shared/date

// handlerでcaseを使うのは1回まで
pub fn post(
  req: wisp.Request,
  save_loan: domain.SaveLoan,
  current_date: fn() -> date.Date,
) {
  use json <- wisp.require_json(req)

  let result =
    json
    |> domain.parse_json()
    |> domain.to_loan(current_date)
    |> save_loan()

  case result {
    Ok(_) -> {
      "ok"
      |> json.string()
      |> json_response.ok()
    }
    Error(_) -> {
      "ng" |> json.string() |> json_response.bad_request()
    }
  }
}
