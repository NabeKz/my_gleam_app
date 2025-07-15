import gleam/list
import wisp

import core/book/types/book_id
import core/loan/services/service
import core/loan/types/loan
import shell/adapters/web/handler/helper/json

pub fn get_loans(
  req: wisp.Request,
  get_loans: service.GetLoans,
) -> wisp.Response {
  use params <- json.get_query(req, service.get_loans_params_decoder)

  get_loans(params)
  |> json.array(serialize)
  |> json.ok()
}

pub fn get_loan(id: String, get_loan: service.GetLoan) -> wisp.Response {
  let params = service.generate_get_loan_params(id)

  case get_loan(params) {
    Ok(loan) -> loan |> serialize() |> json.ok()
    Error(_) -> wisp.bad_request()
  }
}

// handlerでcaseを使うのは1回まで
// 極力、handler内でresultを使わない
pub fn create_loan(req: wisp.Request, create_loan: service.CreateLoan) {
  use json <- json.get_body(req, service.create_loan_decoder)

  case create_loan(json) {
    Ok(_) -> wisp.created()
    Error(error) -> {
      error
      |> json.string()
      |> json.bad_request()
    }
  }
}

fn serialize(loan_item: loan.Loan) -> json.Json {
  [
    #("id", loan.id_value(loan_item) |> json.string()),
    #("book_id", loan.book_id(loan_item) |> book_id.to_string |> json.string()),
    #("loan_date", loan.loan_date(loan_item) |> json.string()),
    #("due_date", loan.due_date(loan_item) |> json.string()),
  ]
  |> json.object()
}
