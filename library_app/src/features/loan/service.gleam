import gleam/dynamic/decode
import gleam/option

import features/book/domain as book_domain
import features/book/port/book_id
import features/loan/helper/decoder
import features/loan/loan.{type Loan}
import shared/date

// Command types
pub type SaveLoan =
  fn(Loan) -> Result(Nil, String)

// Query types
pub type GetLoanParams {
  GetLoanParams(loan_id: String)
}

pub type CreateLoanParams {
  CreateLoanParams(book_id: book_id.BookId)
}

pub type GetLoansParams {
  GetLoansParams(loan_date: option.Option(String))
}

pub type GetLoan =
  fn(GetLoanParams) -> Result(Loan, String)

pub type GetLoans =
  fn(GetLoansParams) -> List(Loan)

// Command functions
pub fn create_loan_decoder() -> decode.Decoder(CreateLoanParams) {
  use book_id <- decoder.required_field("book_id", decode.string)
  decode.success(CreateLoanParams(book_id |> book_id.from_string))
}

pub fn create_loan(
  params: CreateLoanParams,
  current_date: fn() -> date.Date,
  check_book_exists: book_domain.CheckBookExists,
  save_loan: SaveLoan,
) -> Result(Nil, String) {
  case check_book_exists(params.book_id) {
    False -> Error("Book does not exist")
    True -> {
      params.book_id
      |> loan.new(current_date())
      |> save_loan()
    }
  }
}

// Query functions
pub fn generate_get_loan_params(loan_id: String) -> GetLoanParams {
  GetLoanParams(loan_id:)
}

pub fn get_loans_params_decoder() -> decode.Decoder(GetLoansParams) {
  use loan_date <- decoder.optional_field("loan_date", decode.string)
  decode.success(GetLoansParams(loan_date))
}
