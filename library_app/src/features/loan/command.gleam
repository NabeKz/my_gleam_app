import gleam/dynamic/decode
import gleam/result

import features/book/port/book_id
import features/loan/loan.{type Loan}
import shared/date

/// events
pub type SaveLoan =
  fn(CreateLoan) -> Result(Nil, String)

pub type CreateLoan =
  Result(Loan, List(decode.DecodeError))

// TODO: book_idの責務
pub fn parse_json() -> decode.Decoder(book_id.BookId) {
  use book_id <- decode.field("book_id", decode.string)
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
