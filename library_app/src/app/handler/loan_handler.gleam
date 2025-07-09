import gleam/json
import wisp

import features/book/port/book_id
import features/loan/domain
import shared/date

pub fn loan(
  req: wisp.Request,
  loan_book: domain.LoanBook,
  book_id: String,
  due_date: String,
) {
  todo
}

pub fn return_book(
  req: wisp.Request,
  return_book: domain.ReturnBook,
  book_id: String,
) {
  todo
}

pub fn get_loan(req: wisp.Request, get_loan: domain.GetLoan, book_id: String) {
  todo
}
