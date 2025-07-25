import core/loan/library_schedule/library_schedule
import core/shared/types/specify_schedule
import gleam/list
import gleam/option
import gleam/order
import gleam/result

import core/book/book
import core/shared/types/date
import core/shared/types/user
import shell/shared/lib/uuid

// repository
pub type GetLoan =
  fn(GetLoanParams) -> Result(Loan, String)

pub type GetLoanByBookId =
  fn(book.BookId) -> Result(Loan, String)

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

// update
pub type UpdateLoan =
  fn(Loan) -> Result(Loan, String)

pub type UpdateLoanParams {
  UpdateLoanParams(book_id: book.BookId)
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
  schedule_list: List(specify_schedule.SpecifySchedule),
) -> Result(Loan, String) {
  let due_date =
    current_date
    |> date.add_days(14)
    |> library_schedule.find_due_date(schedule_list)

  use due_date <- result.try(due_date)

  Loan(
    id: new_id(),
    book_id:,
    user_id:,
    loan_date: current_date,
    due_date:,
    return_date: option.None,
  )
  |> Ok()
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

pub fn return_book(loan: Loan, return_date: date.Date) -> Result(Loan, String) {
  case loan.return_date {
    option.Some(_) -> Error("すでに返却済です")
    option.None -> {
      let loan = Loan(..loan, return_date: option.Some(return_date))
      Ok(loan)
    }
  }
}
