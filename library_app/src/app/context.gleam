import core/auth/auth_provider
import core/book/application/book_command
import core/book/application/book_query
import core/book/domain/book_repository
import core/loan/application/loan_command
import core/loan/application/loan_query
import core/loan/domain/loan_repository
import core/shared/ports/schedule_repository
import core/shared/types/auth
import core/shared/types/date
import shell/adapters/persistence/book_repo_on_ets
import shell/adapters/persistence/loan_repo_on_ets
import shell/adapters/persistence/specify_schedule_repo_on_ets

// Context = 前提条件のみ
pub type Context {
  Context(authenticated: auth.AuthContext, current_date: date.GetDate)
}

// Operations = 文脈固定済みの操作群
pub type Operations {
  Operations(book: BookOperations, loan: LoanOperations)
}

pub type BookOperations {
  BookOperations(
    search: book_query.GetBooksWorkflow,
    create: book_command.CreateBookWorkflow,
    update: book_command.UpdateBookWorkflow,
    delete: book_command.DeleteBookWorkflow,
  )
}

pub type LoanOperations {
  LoanOperations(
    create: loan_command.CreateLoan,
    update: loan_command.ReturnLoan,
    extend: loan_command.ExtendLoan,
    get: loan_query.GetLoan,
    get_all: loan_query.GetLoans,
  )
}

// Repository interfaces
pub type Repositories {
  Repositories(
    book: book_repository.BookRepository,
    loan: loan_repository.LoanRepository,
    schedule: schedule_repository.ScheduleRepository,
  )
}

// Context作成関数
pub fn new() -> Context {
  Context(authenticated: auth_provider.on_mock(), current_date: fn() {
    date.now().date
  })
}

pub fn on_ets() -> Context {
  Context(authenticated: auth_provider.on_mock(), current_date: fn() {
    date.now().date
  })
}

// Repository作成関数
pub fn mock_repositories() -> Repositories {
  Repositories(
    book: book_repository.BookRepository(
      search: fn(_) { [] },
      create: fn(_) { Ok(Nil) },
      read: fn(_) { Error(["not implemented"]) },
      update: fn(_) { Ok(Nil) },
      delete: fn(_) { Ok(Nil) },
      exists: fn(_) { Error("not implemented") },
    ),
    loan: loan_repository.LoanRepository(
      get_loans: fn(_) { [] },
      get_loan: fn(_) { Error(["not implemented"]) },
      get_loan_by_id: fn(_) { Error(["not implemented"]) },
      save_loan: fn(_) { Ok(Nil) },
      put_loan: fn(_) { Ok(Nil) },
      extend_loan: fn(_) { Ok(Nil) },
    ),
    schedule: schedule_repository.ScheduleRepository(
      get_specify_schedules: fn(_) { [] },
    ),
  )
}

pub fn ets_repositories() -> Repositories {
  Repositories(
    book: book_repo_on_ets.new(),
    loan: loan_repo_on_ets.new(),
    schedule: specify_schedule_repo_on_ets.new(),
  )
}

// Operations作成関数（文脈とRepositoryを組み合わせて部分適用）
pub fn create_operations(ctx: Context, repos: Repositories) -> Operations {
  Operations(
    book: BookOperations(
      search: book_query.compose_search_books(_, repos.book.search),
      create: book_command.create_book_workflow(repos.book.create),
      update: book_command.update_book_workflow(
        repos.book.read,
        repos.book.update,
      ),
      delete: book_command.delete_book_workflow(repos.book.delete),
    ),
    loan: LoanOperations(
      create: loan_command.create_loan_workflow(
        ctx.current_date,
        repos.book.exists,
        repos.schedule.get_specify_schedules,
        repos.loan.get_loans,
        repos.loan.save_loan,
      ),
      update: loan_command.return_book_workflow(
        ctx.current_date,
        repos.loan.get_loan_by_id,
        repos.loan.put_loan,
      ),
      extend: loan_command.extend_loan_workflow(
        ctx.current_date,
        repos.schedule.get_specify_schedules,
        repos.loan.get_loan,
        repos.loan.extend_loan,
      ),
      get: repos.loan.get_loan,
      get_all: repos.loan.get_loans,
    ),
  )
}
