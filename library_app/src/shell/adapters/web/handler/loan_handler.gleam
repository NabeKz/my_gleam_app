import wisp

import app/context
import core/book/domain/book
import core/loan/application/loan_query
import core/loan/domain/loan
import core/shared/types/date
import shell/adapters/web/handler/helper/json

pub fn get_loans(req: wisp.Request, ops: context.Operations) -> wisp.Response {
  use params <- json.get_query(req, loan_query.get_loans_params_decoder)

  ops.loan.get_all(params)
  |> json.array(serialize)
  |> json.ok()
}

pub fn get_loan(id: String, ops: context.Operations) -> wisp.Response {
  let params = loan_query.generate_get_loan_params(id)

  case ops.loan.get(params) {
    Ok(loan) -> loan |> serialize() |> json.ok()
    Error(_) -> wisp.bad_request()
  }
}

// handlerでcaseを使うのは1回まで
// 極力、handler内でresultを使わない
pub fn create_loan(
  req: wisp.Request,
  ctx: context.Context,
  ops: context.Operations,
  book_id: String,
) -> wisp.Response {
  use user <- json.authenticated(req, ctx.authenticated)

  case ops.loan.create(user, book_id) {
    Ok(_) -> wisp.created()
    Error(error) -> json.bad_request(error |> json.array(json.string))
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
    #("extension_count", loan.extension_count |> json.int()),
  ]
  |> json.object()
}

pub fn update_loan_by_return_book(
  book_id: String,
  ops: context.Operations,
) -> wisp.Response {
  case ops.loan.update(book_id) {
    Ok(_) -> wisp.no_content()
    Error(error) -> json.bad_request(error |> json.array(json.string))
  }
}

pub fn extend_loan(
  loan_id: String,
  ops: context.Operations,
) -> wisp.Response {
  case ops.loan.extend(loan_id) {
    Ok(_) -> wisp.no_content()
    Error(error) -> json.bad_request(error |> json.array(json.string))
  }
}
