import features/book/port/book_id
import shared/date
import shared/lib/uuid

pub opaque type Loan {
  Loan(
    id: LoanId,
    book_id: book_id.BookId,
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

pub fn new(book_id: book_id.BookId, current_date: date.Date) -> Loan {
  let due_date = current_date |> date.add_days(14)
  Loan(id: new_id(), book_id:, loan_date: current_date, due_date:)
}

pub fn deserialize(loan: Loan) -> List(#(String, String)) {
  [
    #("id", loan.id.value),
    #("book_id", loan.book_id |> book_id.to_string),
    #("due_date", loan.due_date |> date.to_string),
  ]
}
