import wisp

import app/handler/helper/json
import features/loan/service
import shared/date

pub fn get_loans(
  req: wisp.Request,
  get_loans: service.GetLoans,
) -> wisp.Response {
  use params <- json.get_query(req, service.get_loans_params_decoder)

  service.get_loans(params, get_loans)
  |> json.loans_to_json_data()
  |> json.array()
  |> json.ok()
}

pub fn get_loan(
  req: wisp.Request,
  _id: String,
  get_loan: service.GetLoan,
) -> wisp.Response {
  use params <- json.get_query(req, service.get_loan_params_decoder)

  case service.get_loan(params, get_loan) {
    Ok(loan) ->
      loan
      |> json.loan_to_json_data()
      |> json.object()
      |> json.ok()
    Error(_) -> wisp.bad_request()
  }
}

// handlerでcaseを使うのは1回まで
pub fn create_loan(
  req: wisp.Request,
  save_loan: service.SaveLoan,
  current_date: fn() -> date.Date,
) {
  use json <- json.get_body(req, service.create_loan_decoder)

  let result =
    Ok(json)
    |> service.to_loan(current_date)
    |> save_loan()

  case result {
    Ok(_) -> wisp.created()
    Error(_) -> wisp.bad_request()
  }
}
