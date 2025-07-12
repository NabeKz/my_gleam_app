import features/book/domain as book_usecase
import features/loan/command as loan_usecase
import features/loan/query as loan_query
import shared/date

pub type Context {
  Context(
    current_date: fn() -> date.Date,
    search_books: book_usecase.SearchBooks,
    save_loan: loan_usecase.SaveLoan,
    get_loan: loan_query.GetLoan,
  )
}

pub fn new() -> Context {
  Context(
    current_date: date.now,
    search_books: book_usecase.compose_search_books(_, fn(_) { [] }),
    save_loan: loan_usecase.compose_create_loan(_, fn(_) { Ok(Nil) }),
    get_loan: fn(_) { todo },
  )
}
