import features/book/domain as book_usecase
import features/loan/domain as loan_usecase
import shared/date

pub type Context {
  Context(
    current_date: fn() -> date.Date,
    search_books: book_usecase.SearchBooks,
    loan_book: loan_usecase.LoanBook,
    return_book: loan_usecase.ReturnBook,
    get_loan: loan_usecase.GetLoan,
  )
}

pub fn new() -> Context {
  Context(
    current_date: date.now,
    search_books: book_usecase.compose_search_books(_, fn(_) { [] }),
    loan_book: fn(_, _) { todo },
    return_book: fn(_) { todo },
    get_loan: fn(_) { todo },
  )
}
