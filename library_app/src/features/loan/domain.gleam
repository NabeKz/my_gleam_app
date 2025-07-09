import shared/date
import shared/domain/book/book_id

pub type Loan {
  Loan(book_id: book_id.BookId, due_date: date.Date)
}
