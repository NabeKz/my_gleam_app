import gleam/option

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
  CreateLoanParams(book_id: String, user_id: user.UserId)
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
