import core/book/types/book as book_usecase
import core/loan/services/service as loan_service
import core/shared/types/date
import shell/adapters/persistence/book_repo_on_ets
import shell/adapters/persistence/loan_repo_on_ets

pub type Context {
  Context(
    search_books: book_usecase.SearchBooks,
    create_loan: loan_service.CreateLoan,
    get_loan: loan_service.GetLoan,
    get_loans: loan_service.GetLoans,
  )
}

pub fn new() -> Context {
  Context(
    search_books: book_usecase.compose_search_books(_, fn(_) { [] }),
    create_loan: fn(_) { Ok(Nil) },
    get_loan: fn(_) { todo },
    get_loans: fn(_) { [] },
  )
}

pub fn on_ets() -> Context {
  let book_repo = book_repo_on_ets.new()
  let loan_repo = loan_repo_on_ets.new()
  Context(
    search_books: book_usecase.compose_search_books(_, fn(_) { [] }),
    create_loan: loan_service.create_loan(
      _,
      date.now,
      book_repo_on_ets.exits(_, book_repo),
      loan_repo_on_ets.save_loan(_, loan_repo),
    ),
    get_loans: loan_repo_on_ets.get_loans(_, loan_repo),
    get_loan: loan_repo_on_ets.get_loan(_, loan_repo),
  )
}
