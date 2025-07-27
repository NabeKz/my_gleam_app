import gleam/dynamic/decode

import core/loan/domain/loan
import core/loan/domain/loan_repository
import core/shared/helper/decoder

pub type GetLoan =
  fn(loan_repository.GetLoanParams) -> Result(loan.Loan, String)

pub type GetLoans =
  fn(loan_repository.GetLoansParams) -> List(loan.Loan)

// Query functions
pub fn generate_get_loan_params(
  loan_id: String,
) -> loan_repository.GetLoanParams {
  loan_repository.GetLoanParams(loan_id:)
}

pub fn get_loans_params_decoder() -> decode.Decoder(
  loan_repository.GetLoansParams,
) {
  use loan_date <- decoder.optional_field("loan_date", decode.string)
  decode.success(loan_repository.GetLoansParams(loan_date))
}
