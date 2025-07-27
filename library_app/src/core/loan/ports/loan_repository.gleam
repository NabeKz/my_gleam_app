import core/book/domain/book
import core/loan/loan

pub type LoanRepository {
  LoanRepository(
    get_loans: fn(loan.GetLoansParams) -> List(loan.Loan),
    get_loan: fn(loan.GetLoanParams) -> Result(loan.Loan, String),
    get_loan_by_id: fn(book.BookId) -> Result(loan.Loan, String),
    save_loan: fn(loan.Loan) -> Result(Nil, String),
    put_loan: fn(loan.Loan) -> Result(Nil, List(String)),
  )
}
