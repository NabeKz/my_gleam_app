import gleam/dynamic/decode
import gleam/list
import gleam/option

import features/loan/loan.{type Loan}

/// events
pub type GetLoanParams {
  GetLoanParams(loan_id: String)
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

  decode.success(GetLoanParams(loan_id))
}

pub fn decoder2() -> decode.Decoder(GetLoansParams) {
  use loan_date <- decode.optional_field(
    "loan_date",
    option.None,
    decode.string |> decode.optional,
  )

  decode.success(GetLoansParams(loan_date))
}

pub fn encode(loan: List(loan.Loan)) -> List(List(#(String, String))) {
  loan
  |> list.map(loan.deserialize)
}

pub fn compose_get_loan(params: GetLoanParams, get_loan: GetLoan) {
  get_loan(params)
}

pub fn get_loan(crate_params: GetLoanParams, get_loan: GetLoan) {
  crate_params
  |> get_loan
}

pub fn get_loans(crate_params: GetLoansParams, get_loans: GetLoans) {
  crate_params
  |> get_loans
}

pub fn compose_get_loans(params: GetLoansParams, get_loans: GetLoans) {
  get_loans(params)
}
