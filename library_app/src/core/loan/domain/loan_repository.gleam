import gleam/option

import core/book/domain/book
import core/loan/domain/loan

pub type LoanRepository {
  LoanRepository(
    get_loans: GetLoans,
    get_loan: GetLoan,
    get_loan_by_id: GetLoanByBookId,
    save_loan: SaveLoan,
    put_loan: UpdateLoan,
    extend_loan: ExtendLoan,
  )
}

// repository
pub type GetLoan =
  fn(GetLoanParams) -> Result(loan.Loan, List(String))

pub type GetLoanByBookId =
  fn(book.BookId) -> Result(loan.Loan, List(String))

pub type GetLoans =
  fn(GetLoansParams) -> List(loan.Loan)

pub type SaveLoan =
  fn(loan.Loan) -> Result(Nil, List(String))

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
  fn(loan.Loan) -> Result(Nil, List(String))

pub type ExtendLoan =
  fn(loan.Loan) -> Result(Nil, List(String))

pub type UpdateLoanParams {
  UpdateLoanParams(book_id: book.BookId)
}
