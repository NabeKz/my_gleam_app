import gleam/json
import wisp

import app/handler/json_helper
import features/loan/command
import shared/date

// handlerでcaseを使うのは1回まで
pub fn post(
  req: wisp.Request,
  save_loan: command.SaveLoan,
  current_date: fn() -> date.Date,
) {
  use json <- json_helper.require_json(req, command.parse_json)

  let result =
    Ok(json)
    |> command.to_loan(current_date)
    |> save_loan()

  case result {
    Ok(_) -> {
      wisp.created()
    }
    Error(_) -> {
      "ng" |> json.string() |> json_helper.bad_request()
    }
  }
}
