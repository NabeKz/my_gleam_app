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
pub type GetLoanParams {
  GetLoanParams(loan_id: LoanId)
}

pub type GetLoansParams {
  GetLoansParams(loan_id: LoanId)
}

pub type GetLoan =
  fn(GetLoanParams) -> Result(Loan, String)

pub type GetLoans =
  fn(GetLoansParams) -> List(Loan)

pub fn decoder() -> decode.Decoder(GetLoanParams) {
  use loan_id <- decode.field("loan_id", decode.string)

  decode.success(GetLoanParams(LoanId(loan_id)))
}

pub fn compose_get_loan(params: GetLoanParams, get_loan: GetLoan) {
  get_loan(params)
}

pub fn invoke(
  crate_params: Result(GetLoanParams, List(decode.DecodeError)),
  get_loan: GetLoan,
) {
  crate_params
  |> result.replace_error("ng")
  |> result.map(get_loan)
}

pub fn compose_get_loans(params: GetLoansParams, get_loans: GetLoans) {
  get_loans(params)
}
