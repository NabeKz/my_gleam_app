import gleam/dynamic/decode

import core/loan/loan
import core/shared/helper/decoder

pub type GetLoan =
  fn(loan.GetLoanParams) -> Result(loan.Loan, String)

pub type GetLoans =
  fn(loan.GetLoansParams) -> List(loan.Loan)

// Query functions
pub fn generate_get_loan_params(loan_id: String) -> loan.GetLoanParams {
  loan.GetLoanParams(loan_id:)
}

pub fn get_loans_params_decoder() -> decode.Decoder(loan.GetLoansParams) {
  use loan_date <- decoder.optional_field("loan_date", decode.string)
  decode.success(loan.GetLoansParams(loan_date))
}
