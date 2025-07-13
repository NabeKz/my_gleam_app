import features/book/port/book_id
import features/loan/loan
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

pub fn get_loans(conn: LoanRepo) {
  conn.all()
}

pub fn save_loan(conn: LoanRepo, loan: loan.Loan) {
  conn.create(#(loan |> loan.id_value, loan))
}
