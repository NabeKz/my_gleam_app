import features/book/domain as book_usecase
import features/loan/domain as loan_usecase

pub type Context {
  Context(
    search_books: book_usecase.SearchBooks,
    loan_book: loan_usecase.LoanBook,
    return_book: loan_usecase.ReturnBook,
    get_loan: loan_usecase.GetLoan,
  )
}

pub fn new() -> Context {
  Context(
    search_books: book_usecase.compose_search_books(_, fn(_) { [] }),
    loan_book: todo,
    return_book: todo,
    get_loan: todo,
  )
}
