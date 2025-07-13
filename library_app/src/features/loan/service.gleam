import gleam/dynamic/decode
import gleam/option
import gleam/result

import features/book/port/book_id
import features/loan/helper/decoder
import features/loan/loan.{type Loan}
import shared/date

// Command types
pub type SaveLoan =
  fn(CreateLoan) -> Result(Nil, String)

pub type CreateLoan =
  Result(Loan, List(decode.DecodeError))

// Query types
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

// Command functions
pub fn create_loan_decoder() -> decode.Decoder(book_id.BookId) {
  use book_id <- decoder.required_field("book_id", decode.string)
  decode.success(book_id |> book_id.from_string)
}

pub fn to_loan(
  get_book_id: Result(book_id.BookId, List(decode.DecodeError)),
  current_date: fn() -> date.Date,
) -> Result(Loan, List(decode.DecodeError)) {
  use book_id <- result.try(get_book_id)

  loan.new(book_id, current_date())
  |> Ok
}

pub fn compose_create_loan(
  create_loan: CreateLoan,
  save_loan: SaveLoan,
) -> Result(Nil, String) {
  case create_loan |> save_loan() {
    Ok(_) -> Ok(Nil)
    Error(_) -> Error("ng")
  }
}

// Query functions
pub fn get_loan_params_decoder() -> decode.Decoder(GetLoanParams) {
  use loan_id <- decoder.required_field("loan_id", decode.string)
  decode.success(GetLoanParams(loan_id))
}

pub fn get_loans_params_decoder() -> decode.Decoder(GetLoansParams) {
  use loan_date <- decoder.optional_field("loan_date", decode.string)
  decode.success(GetLoansParams(loan_date))
}

pub fn get_loan(params: GetLoanParams, get_loan: GetLoan) {
  params |> get_loan
}

pub fn get_loans(params: GetLoansParams, get_loans: GetLoans) {
  params |> get_loans
}
