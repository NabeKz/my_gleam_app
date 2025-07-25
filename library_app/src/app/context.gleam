import core/auth/auth_provider
import core/book/book_command
import core/book/book_ports
import core/book/book_query
import core/loan/loan_command
import core/loan/loan_query
import core/shared/types/auth
import core/shared/types/date
import shell/adapters/persistence/book_repo_on_ets
import shell/adapters/persistence/loan_repo_on_ets
import shell/adapters/persistence/specify_schedule_repo_on_ets

pub type Context {
  Context(
    authenticated: auth.AuthContext,
    current_date: date.GetDate,
    search_books: book_ports.GetBooksWorkflow,
    create_book: book_ports.CreateBookWorkflow,
    create_loan: loan_command.CreateLoan,
    update_loan: loan_command.ReturnLoan,
    get_loan: loan_query.GetLoan,
    get_loans: loan_query.GetLoans,
  )
}

fn now() {
  date.now().date
}

pub fn new() -> Context {
  Context(
    authenticated: auth_provider.on_mock(),
    current_date: now,
    search_books: book_query.compose_search_books(_, fn(_) { [] }),
    create_book: fn(_) { Ok(Nil) },
    create_loan: fn(_, _) { Ok(Nil) },
    update_loan: fn(_) { Error("not implements") },
    get_loan: fn(_) { Error("error") },
    get_loans: fn(_) { [] },
  )
}

pub fn on_ets() -> Context {
  let book_repo = book_repo_on_ets.new()
  let loan_repo = loan_repo_on_ets.new()
  let specify_schedule_repo = specify_schedule_repo_on_ets.new()
  Context(
    authenticated: auth_provider.on_mock(),
    current_date: now,
    search_books: book_query.compose_search_books(
      _,
      book_repo_on_ets.search_books(_, book_repo),
    ),
    create_book: book_command.create_book_workflow(book_repo_on_ets.create(
      _,
      book_repo,
    )),
    create_loan: loan_command.create_loan_workflow(
      now,
      book_repo_on_ets.exits(_, book_repo),
      specify_schedule_repo_on_ets.get_specify_schedules(
        _,
        specify_schedule_repo,
      ),
      loan_repo_on_ets.get_loans(_, loan_repo),
      loan_repo_on_ets.save_loan(_, loan_repo),
    ),
    update_loan: loan_command.return_book_workflow(
      now,
      loan_repo_on_ets.get_loan_by_id(_, loan_repo),
      loan_repo_on_ets.put_loan(_, loan_repo),
    ),
    get_loans: loan_repo_on_ets.get_loans(_, loan_repo),
    get_loan: loan_repo_on_ets.get_loan(_, loan_repo),
  )
}
