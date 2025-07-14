import features/book/domain as book_usecase
import features/loan/loan_repo_on_ets
import features/loan/service as loan_service
import shared/date

pub type Context {
  Context(
    current_date: fn() -> date.Date,
    search_books: book_usecase.SearchBooks,
    check_book_exists: book_usecase.CheckBookExists,
    save_loan: loan_service.SaveLoan,
    get_loan: loan_service.GetLoan,
    get_loans: loan_service.GetLoans,
  )
}

pub fn new() -> Context {
  Context(
    current_date: date.now,
    search_books: book_usecase.compose_search_books(_, fn(_) { [] }),
    check_book_exists: fn(_) { True },
    save_loan: fn(_) { Ok(Nil) },
    get_loan: fn(_) { todo },
    get_loans: fn(_) { todo },
  )
}

pub fn on_ets() -> Context {
  let loan_repo = loan_repo_on_ets.new()
  Context(
    current_date: date.now,
    search_books: book_usecase.compose_search_books(_, fn(_) { [] }),
    check_book_exists: fn(_) { True },
    get_loans: loan_repo_on_ets.get_loans(_, loan_repo),
    get_loan: loan_repo_on_ets.get_loan(_, loan_repo),
    save_loan: loan_repo_on_ets.save_loan(_, loan_repo),
  )
}
