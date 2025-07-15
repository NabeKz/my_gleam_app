import core/book/book
import core/shared/types/date
import shell/shared/lib/uuid

pub type Loan {
  Loan(
    id: LoanId,
    book_id: book.BookId,
    loan_date: date.Date,
    due_date: date.Date,
  )
}

pub opaque type LoanId {
  LoanId(value: String)
}

fn new_id() -> LoanId {
  LoanId(uuid.v4())
}

pub fn new(book_id: book.BookId, current_date: date.Date) -> Loan {
  let due_date = current_date |> date.add_days(14)
  Loan(id: new_id(), book_id:, loan_date: current_date, due_date:)
}

// Getter functions for accessing opaque type fields
pub fn id_value(loan: Loan) -> String {
  loan.id.value
}
