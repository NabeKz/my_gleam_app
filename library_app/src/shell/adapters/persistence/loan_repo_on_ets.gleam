import core/book/types/book_id
import core/loan/types/loan
import core/loan/services/service
import core/shared/types/date
import shell/shared/lib/ets

type LoanRepo =
  ets.Conn(String, loan.Loan)

pub fn new() -> LoanRepo {
  ets.conn(
    "loans",
    [
      loan.new(book_id.new(), date.from(#(2025, 7, 31))),
      loan.new(book_id.new(), date.from(#(2025, 8, 1))),
    ],
    fn(it) { it |> loan.id_value },
  )
}

pub fn get_loans(_params: service.GetLoansParams, conn: LoanRepo) {
  conn.all()
}

pub fn get_loan(
  params: service.GetLoanParams,
  conn: LoanRepo,
) -> Result(loan.Loan, String) {
  conn.get(params.loan_id)
}

pub fn save_loan(loan: loan.Loan, conn: LoanRepo) {
  conn.create(#(loan |> loan.id_value, loan))
}
