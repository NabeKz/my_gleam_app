import features/book/port/book_id
import features/loan/loan
import features/loan/service
import shared/date
import shared/lib/ets

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
