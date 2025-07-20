import gleam/list
import gleam/option
import gleam/order

import core/book/book
import core/shared/types/date
import core/shared/types/user
import shell/shared/lib/uuid

// repository
pub type GetLoan =
  fn(GetLoanParams) -> Result(Loan, String)

pub type GetLoans =
  fn(GetLoansParams) -> List(Loan)

pub type SaveLoan =
  fn(Loan) -> Result(Nil, String)

pub type GetLoanParams {
  GetLoanParams(loan_id: String)
}

pub type GetLoansParams {
  GetLoansParams(loan_date: option.Option(String))
}

pub type CreateLoanParams {
  CreateLoanParams(book_id: String)
}

// domain model
pub type Loan {
  Loan(
    id: LoanId,
    book_id: book.BookId,
    user_id: user.UserId,
    loan_date: date.Date,
    due_date: date.Date,
    return_date: option.Option(date.Date),
  )
}

pub opaque type LoanId {
  LoanId(value: String)
}

fn new_id() -> LoanId {
  LoanId(uuid.v4())
}

pub fn new(
  book_id: book.BookId,
  user_id: user.UserId,
  current_date: date.Date,
) -> Loan {
  Loan(
    id: new_id(),
    book_id:,
    user_id:,
    loan_date: current_date,
    due_date: current_date |> date.add_days(14),
    return_date: option.None,
  )
}

// Getter functions for accessing opaque type fields
pub fn id_value(loan: Loan) -> String {
  loan.id.value
}

fn is_overdue(loan: Loan, current_date: date.Date) -> Bool {
  date.compare(current_date, order.Gt, loan.due_date)
  && option.is_none(loan.return_date)
}

pub fn has_overdue(loans: List(Loan), current_date: date.Date) -> Bool {
  use loan <- list.any(loans)
  loan |> is_overdue(current_date)
}

pub fn is_loan_limit(loans: List(Loan)) -> Bool {
  list.length(loans) >= 10
}
