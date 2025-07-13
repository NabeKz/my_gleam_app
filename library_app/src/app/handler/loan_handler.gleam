import features/loan/query
import gleam/json
import wisp

import app/handler/json_helper
import features/loan/command
import shared/date

pub fn get(req: wisp.Request, get_loan: query.GetLoan) -> wisp.Response {
  let params = json_helper.get_query(req, query.decoder)

  case query.get_loan(params, get_loan) {
    Ok(_) -> wisp.ok()
    Error(_) -> wisp.bad_request()
  }
}

pub fn gets(req: wisp.Request, get_loans: query.GetLoans) -> wisp.Response {
  let params = json_helper.get_query(req, query.decoder2)

  case query.get_loans(params, get_loans) {
    Ok(_) -> wisp.ok()
    Error(_) -> wisp.bad_request()
  }
}

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
    Ok(_) -> wisp.created()
    Error(_) -> "ng" |> json.string() |> json_helper.bad_request()
  }
}
