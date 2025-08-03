import gleam/list
import gleam/result

import core/book/domain/book
import core/loan/domain/loan
import core/loan/domain/loan_repository
import core/shared/types/date
import core/shared/types/user
import shell/shared/lib/ets

type LoanRepo =
  ets.Conn(String, loan.Loan)

pub fn new() -> loan_repository.LoanRepository {
  let conn = create_conn()

  loan_repository.LoanRepository(
    get_loans: get_loans(_, conn),
    get_loan: get_loan(_, conn),
    get_loan_by_id: get_loan_by_id(_, conn),
    save_loan: save_loan(_, conn),
    put_loan: put_loan(_, conn),
    extend_loan: extend_loan(_, conn),
  )
}

fn create_conn() -> LoanRepo {
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

fn get_loans(_params: loan_repository.GetLoansParams, conn: LoanRepo) {
  conn.all()
}

fn get_loan(
  params: loan_repository.GetLoanParams,
  conn: LoanRepo,
) -> Result(loan.Loan, List(String)) {
  conn.get(params.loan_id)
  |> result.map_error(fn(it) { [it] })
}

fn get_loan_by_id(
  book_id: book.BookId,
  conn: LoanRepo,
) -> Result(loan.Loan, List(String)) {
  let rows = conn.all()

  list.find(rows, fn(it) { it.book_id == book_id })
  |> result.replace_error(["貸出履歴が見つかりません"])
}

fn save_loan(loan: loan.Loan, conn: LoanRepo) -> Result(Nil, List(String)) {
  conn.create(#(loan |> loan.id_value, loan))
  |> result.map_error(fn(it) { [it] })
}

fn put_loan(loan: loan.Loan, conn: LoanRepo) -> Result(Nil, List(String)) {
  conn.update(#(loan |> loan.id_value, loan))
}

fn extend_loan(loan: loan.Loan, conn: LoanRepo) -> Result(Nil, List(String)) {
  conn.update(#(loan |> loan.id_value, loan))
}
