import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import gleam/result

import features/book/port/book_id
import shared/date

/// model
pub opaque type Loan {
  Loan(
    id: LoanId,
    book_id: book_id.BookId,
    loan_date: date.Date,
    due_date: date.Date,
  )
}

pub opaque type LoanId {
  LoanId(value: String)
}

pub fn new(
  id: LoanId,
  book_id: book_id.BookId,
  loan_date: date.Date,
  due_date: date.Date,
) {
  Loan(id:, book_id:, loan_date:, due_date:)
}

/// events
pub type Params {
  Params(loan_id: LoanId)
}

pub type GetLoan =
  fn(Params) -> Result(Loan, String)

pub fn decoder() -> decode.Decoder(Params) {
  use loan_id <- decode.field("loan_id", decode.string)

  decode.success(Params(LoanId(loan_id)))
}

pub fn compose_get_loan(query: Params, get_loan: GetLoan) {
  get_loan(query)
}
