import gleam/dynamic/decode
import gleam/result

import core/book/book
import core/loan/loan
import core/shared/helper/decoder
import core/shared/types/date

pub type CreateLoan =
  fn(loan.CreateLoanParams) -> Result(Nil, String)

// Command functions
// TODO: 延滞や貸出上限の制限を追加する
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
