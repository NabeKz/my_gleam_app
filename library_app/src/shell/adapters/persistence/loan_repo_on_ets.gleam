import core/book/book
import core/loan/types/loan
import core/loan/types/loan_repository
import core/shared/types/date
import shell/shared/lib/ets

type LoanRepo =
  ets.Conn(String, loan.Loan)

pub fn new() -> LoanRepo {
  let assert Ok(book1) = book.new("hoge", "a")
  let assert Ok(book2) = book.new("fuga", "b")
  ets.conn(
    [
      loan.new(book1.id, date.from(#(2025, 7, 31))),
      loan.new(book2.id, date.from(#(2025, 8, 1))),
    ],
    fn(it) { it |> loan.id_value },
  )
}

pub fn get_loans(_params: loan_repository.GetLoansParams, conn: LoanRepo) {
  conn.all()
}

pub fn get_loan(
  params: loan_repository.GetLoanParams,
  conn: LoanRepo,
) -> Result(loan.Loan, String) {
  conn.get(params.loan_id)
}

pub fn save_loan(loan: loan.Loan, conn: LoanRepo) {
  conn.create(#(loan |> loan.id_value, loan))
}
