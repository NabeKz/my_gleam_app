import wisp

import app/handler/helper/json
import features/loan/command
import features/loan/query
import shared/date

pub fn get_loans(req: wisp.Request, get_loans: query.GetLoans) -> wisp.Response {
  use params <- json.get_query(req, query.decoder2)

  query.get_loans(params, get_loans)
  wisp.ok()
}

pub fn get_loan(
  req: wisp.Request,
  id: String,
  get_loan: query.GetLoan,
) -> wisp.Response {
  use params <- json.get_query(req, query.decoder)

  case query.get_loan(params, get_loan) {
    Ok(_) -> wisp.ok()
    Error(_) -> wisp.bad_request()
  }
}

// handlerでcaseを使うのは1回まで
pub fn create_loan(
  req: wisp.Request,
  save_loan: command.SaveLoan,
  current_date: fn() -> date.Date,
) {
  use json <- json.get_body(req, command.parse_json)

  let result =
    Ok(json)
    |> command.to_loan(current_date)
    |> save_loan()

  case result {
    Ok(_) -> wisp.created()
    Error(_) -> wisp.bad_request()
  }
}
