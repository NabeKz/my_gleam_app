import gleam/option
import gleam/result

import core/book/domain/book
import core/book/domain/book_repository
import core/loan/domain/loan
import core/loan/domain/loan_repository
import core/shared/types/date
import core/shared/types/specify_schedule
import core/shared/types/user

pub type CreateLoan =
  fn(user.User, String) -> Result(Nil, String)

pub type ReturnLoan =
  fn(String) -> Result(Nil, String)

// バリデーション済みユーザーを表す型
type ValidatedUser {
  ValidatedUser(user: user.User)
}

// Command functions
pub fn create_loan_workflow(
  current_date: fn() -> date.Date,
  check_book_exists: book_repository.CheckBookExists,
  get_specify_schedules: specify_schedule.GetSpecifySchedulesAfterCurrentDate,
  get_loans: loan_repository.GetLoans,
  save_loan: loan_repository.SaveLoan,
) -> CreateLoan {
  fn(user: user.User, book_id: String) -> Result(Nil, String) {
    use book_id <- result.try(check_book_exists(book_id))
    use validated_user <- result.try(validate_user_loan_eligibility(
      user,
      current_date(),
      get_loans,
    ))
    use loan <- result.try(create_loan_with_schedule(
      validated_user,
      book_id,
      current_date,
      get_specify_schedules,
    ))
    save_loan(loan)
  }
}

// Pure helper functions
fn validate_user_loan_eligibility(
  user: user.User,
  current_date: date.Date,
  get_loans: loan_repository.GetLoans,
) -> Result(ValidatedUser, String) {
  let loans = loan_repository.GetLoansParams(option.None) |> get_loans()

  [validate_no_overdue(loans, current_date), validate_loan_limit(loans)]
  |> result.all()
  |> result.replace(ValidatedUser(user))
}

fn validate_no_overdue(
  loans: List(loan.Loan),
  current_date: date.Date,
) -> Result(Nil, String) {
  case loans |> loan.has_overdue(current_date) {
    True -> Error("延滞を解消してください")
    False -> Ok(Nil)
  }
}

fn validate_loan_limit(loans: List(loan.Loan)) -> Result(Nil, String) {
  case loans |> loan.is_loan_limit() {
    True -> Error("貸出上限です")
    False -> Ok(Nil)
  }
}

fn create_loan_with_schedule(
  validated_user: ValidatedUser,
  book_id: book.BookId,
  current_date: fn() -> date.Date,
  get_specify_schedules: specify_schedule.GetSpecifySchedulesAfterCurrentDate,
) -> Result(loan.Loan, String) {
  let ValidatedUser(user) = validated_user
  let schedules = current_date() |> get_specify_schedules()
  loan.new(book_id, user.id, current_date(), schedules)
}

// Update functions
pub fn return_book_workflow(
  current_date: date.GetDate,
  get_loan_by_book_id: loan_repository.GetLoanByBookId,
  update_loan: loan_repository.UpdateLoan,
) -> ReturnLoan {
  fn(book_id) {
    use loan <- result.try(
      book_id |> book.id_from_string() |> get_loan_by_book_id(),
    )
    // TODO: refactor
    loan.return_book(loan, current_date())
    |> result.map(fn(it) { update_loan(it) |> result.replace_error("") })
    |> result.flatten()
  }
}
