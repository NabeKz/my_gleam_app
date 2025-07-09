import shared/domain/book_id
import shared/date

pub type Loan {
  Loan(book_id: book_id.BookId, due_date: date.Date)
}
