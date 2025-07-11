import gleam/dynamic
import gleam/dynamic/decode
import gleam/result

import features/book/port/book_id
import shared/date

/// model
pub type Loan {
  Loan(book_id: book_id.BookId, loan_date: date.Date, due_date: date.Date)
}

pub fn to_loan(
  get_book_id: Result(book_id.BookId, List(decode.DecodeError)),
  current_date: fn() -> date.Date,
) -> Result(Loan, List(decode.DecodeError)) {
  use book_id <- result.try(get_book_id)

  loan(book_id, current_date())
  |> Ok
}

fn loan(book_id: book_id.BookId, current_date: date.Date) -> Loan {
  let due_date = current_date |> date.add_days(14)
  Loan(book_id:, loan_date: current_date, due_date:)
}

/// events
pub type SaveLoan =
  fn(CreateLoan) -> Result(Nil, String)

pub type CreateLoan =
  Result(Loan, List(decode.DecodeError))

pub type GetLoan =
  fn(book_id.BookId) -> Result(Loan, String)

pub type ReturnBook =
  fn(book_id.BookId) -> Result(Nil, String)

///
///
pub fn parse_json(
  json: dynamic.Dynamic,
) -> Result(book_id.BookId, List(decode.DecodeError)) {
  let decoder = {
    use book_id <- decode.field("book_id", decode.string)
    decode.success(book_id |> book_id.from_string)
  }

  decode.run(json, decoder)
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

pub fn compose_return_book(
  return_book: ReturnBook,
  book_id: book_id.BookId,
) -> Result(Nil, String) {
  return_book(book_id)
}

pub fn compose_get_loan(
  get_loan: GetLoan,
  book_id: book_id.BookId,
) -> Result(Loan, String) {
  get_loan(book_id)
}
