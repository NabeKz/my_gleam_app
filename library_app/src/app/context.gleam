import core/book/book_ports
import core/book/book_query
import core/loan/services/loan_command
import core/loan/types/loan_repository
import core/shared/types/date
import shell/adapters/persistence/book_repo_on_ets
import shell/adapters/persistence/loan_repo_on_ets

pub type Context {
  Context(
    current_date: date.GetDate,
    search_books: book_ports.GetBooksWorkflow,
    create_loan: loan_repository.CreateLoan,
    get_loan: loan_repository.GetLoan,
    get_loans: loan_repository.GetLoans,
  )
}

pub fn new() -> Context {
  Context(
    current_date: date.now,
    search_books: book_query.compose_search_books(_, fn(_) { [] }),
    create_loan: fn(_) { Ok(Nil) },
    get_loan: fn(_) { Error("error") },
    get_loans: fn(_) { [] },
  )
}

pub fn on_ets() -> Context {
  let book_repo = book_repo_on_ets.new()
  let loan_repo = loan_repo_on_ets.new()
  Context(
    current_date: date.now,
    search_books: book_query.compose_search_books(
      _,
      book_repo_on_ets.search_books(_, book_repo),
    ),
    create_loan: loan_command.create_loan_workflow(
      _,
      date.now,
      book_repo_on_ets.exits(_, book_repo),
      loan_repo_on_ets.save_loan(_, loan_repo),
    ),
    get_loans: loan_repo_on_ets.get_loans(_, loan_repo),
    get_loan: loan_repo_on_ets.get_loan(_, loan_repo),
  )
}
