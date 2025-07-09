import features/book/port/book_id
import features/loan/domain
import shared/date

pub type LoanBook =
  fn(book_id.BookId, date.Date) -> Result(domain.Loan, String)

pub type GetLoan =
  fn(book_id.BookId) -> Result(domain.Loan, String)

pub type ReturnBook =
  fn(book_id.BookId) -> Result(Nil, String)

pub fn compose_loan_book(
  loan_book: LoanBook,
  book_id: book_id.BookId,
  due_date: date.Date,
) -> Result(domain.Loan, String) {
  loan_book(book_id, due_date)
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
) -> Result(domain.Loan, String) {
  get_loan(book_id)
}
