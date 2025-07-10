import gleam/dynamic
import gleam/dynamic/decode

import features/book/port/book_id
import shared/date

/// model
pub type Loan {
  Loan(book_id: book_id.BookId, loan_date: date.Date, due_date: date.Date)
}

pub fn loan(book_id: book_id.BookId, current_date: date.Date) -> Loan {
  let due_date = current_date |> date.add_days(14)
  Loan(book_id:, loan_date: current_date, due_date:)
}

/// events
pub type CreateLoan =
  fn(book_id.BookId, date.Date) -> Result(Loan, String)

pub fn parse_json(
  json: dynamic.Dynamic,
) -> Result(book_id.BookId, List(decode.DecodeError)) {
  let decoder = {
    use book_id <- decode.field("book_id", decode.string)
    decode.success(book_id |> book_id.from_string)
  }

  decode.run(json, decoder)
}

pub type GetLoan =
  fn(book_id.BookId) -> Result(Loan, String)

pub type ReturnBook =
  fn(book_id.BookId) -> Result(Nil, String)

pub fn compose_loan_book(
  create_loan: CreateLoan,
  book_id: book_id.BookId,
  due_date: date.Date,
) -> Result(Loan, String) {
  create_loan(book_id, due_date)
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
