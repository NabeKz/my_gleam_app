import gleam/option

import core/loan/types/loan.{type Loan}

// Command types
pub type SaveLoan =
  fn(Loan) -> Result(Nil, String)

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

pub type CreateLoan =
  fn(CreateLoanParams) -> Result(Nil, String)

pub type CreateLoanParams {
  CreateLoanParams(book_id: String)
}
