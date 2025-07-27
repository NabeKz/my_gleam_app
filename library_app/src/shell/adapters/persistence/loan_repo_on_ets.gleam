import gleam/list
import gleam/result

import core/book/book
import core/loan/loan
import core/shared/types/date
import core/shared/types/user
import shell/shared/lib/ets

type LoanRepo =
  ets.Conn(String, loan.Loan)

pub fn new() -> LoanRepo {
  let assert Ok(book1) = book.new("hoge", "a")
  let assert Ok(book2) = book.new("fuga", "b")
  ets.conn(
    [
      loan.new(
        book1.id,
        user.id_from_string("1"),
        date.from(#(2025, 7, 31)),
        [],
      ),
      loan.new(book2.id, user.id_from_string("2"), date.from(#(2025, 8, 1)), []),
    ]
      |> result.values(),
    fn(it) { it |> loan.id_value },
  )
}

pub fn get_loans(_params: loan.GetLoansParams, conn: LoanRepo) {
  conn.all()
}

pub fn get_loan(
  params: loan.GetLoanParams,
  conn: LoanRepo,
) -> Result(loan.Loan, String) {
  conn.get(params.loan_id)
}

pub fn get_loan_by_id(
  book_id: book.BookId,
  conn: LoanRepo,
) -> Result(loan.Loan, String) {
  let rows = conn.all()

  list.find(rows, fn(it) { it.book_id == book_id })
  |> result.replace_error("貸出履歴が見つかりません")
}

pub fn save_loan(loan: loan.Loan, conn: LoanRepo) {
  conn.create(#(loan |> loan.id_value, loan))
}

pub fn put_loan(loan: loan.Loan, conn: LoanRepo) -> Result(Nil, List(String)) {
  conn.update(#(loan |> loan.id_value, loan))
}
