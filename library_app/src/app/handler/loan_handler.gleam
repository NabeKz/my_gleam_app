import wisp

import app/handler/helper/json
import features/loan/service
import shared/date

pub fn get_loans(
  req: wisp.Request,
  get_loans: service.GetLoans,
) -> wisp.Response {
  use params <- json.get_query(req, service.get_loans_params_decoder)

  get_loans(params)
  |> json.loans_to_json_data()
  |> json.array()
  |> json.ok()
}

pub fn get_loan(id: String, get_loan: service.GetLoan) -> wisp.Response {
  let params = service.generate_get_loan_params(id)

  case get_loan(params) {
    Ok(loan) ->
      loan
      |> json.loan_to_json_data()
      |> json.object()
      |> json.ok()
    Error(_) -> wisp.bad_request()
  }
}

// handlerでcaseを使うのは1回まで
// 極力、handler内でresultを使わない
pub fn create_loan(
  req: wisp.Request,
  save_loan: service.SaveLoan,
  current_date: fn() -> date.Date,
) {
  use json <- json.get_body(req, service.create_loan_decoder)

  case service.create_loan(json, current_date, save_loan) {
    Ok(_) -> wisp.created()
    Error(_) -> wisp.bad_request()
  }
}
