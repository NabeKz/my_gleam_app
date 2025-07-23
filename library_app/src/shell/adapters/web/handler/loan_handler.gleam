import wisp

import app/context
import core/book/book
import core/loan/loan
import core/loan/loan_query
import core/shared/types/date
import shell/adapters/web/handler/helper/json

pub fn get_loans(req: wisp.Request, get_loans: loan.GetLoans) -> wisp.Response {
  use params <- json.get_query(req, loan_query.get_loans_params_decoder)

  get_loans(params)
  |> json.array(serialize)
  |> json.ok()
}

pub fn get_loan(id: String, get_loan: loan.GetLoan) -> wisp.Response {
  let params = loan_query.generate_get_loan_params(id)

  case get_loan(params) {
    Ok(loan) -> loan |> serialize() |> json.ok()
    Error(_) -> wisp.bad_request()
  }
}

// handlerでcaseを使うのは1回まで
// 極力、handler内でresultを使わない
pub fn create_loan(
  req: wisp.Request,
  ctx: context.Context,
  book_id: String,
) -> wisp.Response {
  use user <- json.authenticated(req, ctx.authenticated)

  case ctx.create_loan(user, book_id) {
    Ok(_) -> wisp.created()
    Error(error) -> json.bad_request(error |> json.string())
  }
}

fn serialize(loan: loan.Loan) -> json.Json {
  [
    #("id", loan.id_value(loan) |> json.string()),
    #("book_id", loan.book_id |> book.id_to_string |> json.string()),
    #("loan_date", loan.loan_date |> date.to_string() |> json.string()),
    #("due_date", loan.due_date |> date.to_string() |> json.string()),
    #(
      "return_date",
      loan.return_date
        |> json.map_or(date.to_string, "", json.string),
    ),
  ]
  |> json.object()
}

pub fn update_loan_by_return_book(
  book_id: String,
  ctx: context.Context,
) -> wisp.Response {
  case ctx.update_loan(book_id) {
    Ok(_) -> wisp.no_content()
    Error(error) -> json.bad_request(error |> json.string())
  }
}
