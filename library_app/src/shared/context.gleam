import features/book/domain as book_usecase
import features/loan/service as loan_service
import shared/date

pub type Context {
  Context(
    current_date: fn() -> date.Date,
    search_books: book_usecase.SearchBooks,
    save_loan: loan_service.SaveLoan,
    get_loan: loan_service.GetLoan,
    get_loans: loan_service.GetLoans,
  )
}

pub fn new() -> Context {
  Context(
    current_date: date.now,
    search_books: book_usecase.compose_search_books(_, fn(_) { [] }),
    save_loan: loan_service.compose_create_loan(_, fn(_) { Ok(Nil) }),
    get_loan: fn(params) { loan_service.get_loan(params, fn(_) { todo }) },
    get_loans: fn(params) { loan_service.get_loans(params, fn(_) { todo }) },
  )
}
