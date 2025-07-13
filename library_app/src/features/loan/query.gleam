import gleam/dynamic/decode
import gleam/option
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
  GetLoansParams(loan_date: option.Option(String))
}

pub type GetLoan =
  fn(GetLoanParams) -> Result(Loan, String)

pub type GetLoans =
  fn(GetLoansParams) -> List(Loan)

pub fn decoder() -> decode.Decoder(GetLoanParams) {
  use loan_id <- decode.field("loan_id", decode.string)

  decode.success(GetLoanParams(LoanId(loan_id)))
}

pub fn decoder2() -> decode.Decoder(GetLoansParams) {
  use loan_date <- decode.optional_field(
    "loan_date",
    option.None,
    decode.string |> decode.optional,
  )

  decode.success(GetLoansParams(loan_date))
}

pub fn compose_get_loan(params: GetLoanParams, get_loan: GetLoan) {
  get_loan(params)
}

pub fn get_loan(
  crate_params: Result(GetLoanParams, List(decode.DecodeError)),
  get_loan: GetLoan,
) {
  crate_params
  |> result.replace_error("ng")
  |> result.map(get_loan)
}

pub fn get_loans(
  crate_params: Result(GetLoansParams, List(decode.DecodeError)),
  get_loans: GetLoans,
) {
  crate_params
  |> result.replace_error("ng")
  |> result.map(get_loans)
}

pub fn compose_get_loans(params: GetLoansParams, get_loans: GetLoans) {
  get_loans(params)
}
