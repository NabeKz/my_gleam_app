import gleam/dynamic/decode
import gleam/result

import core/book/book
import core/loan/loan
import core/shared/helper/decoder
import core/shared/types/date

pub type CreateLoan =
  fn(loan.CreateLoanParams) -> Result(Nil, String)

// Command functions
pub fn create_loan_workflow(
  params: loan.CreateLoanParams,
  current_date: fn() -> date.Date,
  check_book_exists: book.CheckBookExists,
  save_loan: loan.SaveLoan,
) -> Result(Nil, String) {
  use book_id <- result.try(check_book_exists(params.book_id))
  book_id
  |> loan.new(current_date())
  |> save_loan()
}

pub fn create_loan_decoder() -> decode.Decoder(loan.CreateLoanParams) {
  use book_id <- decoder.required_field("book_id", decode.string)
  decode.success(loan.CreateLoanParams(book_id))
}

// Query functions
pub fn generate_get_loan_params(loan_id: String) -> loan.GetLoanParams {
  loan.GetLoanParams(loan_id:)
}

pub fn get_loans_params_decoder() -> decode.Decoder(loan.GetLoansParams) {
  use loan_date <- decoder.optional_field("loan_date", decode.string)
  decode.success(loan.GetLoansParams(loan_date))
}
