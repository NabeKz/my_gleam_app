import gleam/list
import gleam/option
import gleam/order
import gleam/result

import core/book/domain/book
import core/loan/domain/library_schedule/library_schedule
import core/shared/types/date
import core/shared/types/specify_schedule
import core/shared/types/user
import shell/shared/lib/uuid

// domain model
pub type Loan {
  Loan(
    id: LoanId,
    book_id: book.BookId,
    user_id: user.UserId,
    loan_date: date.Date,
    due_date: date.Date,
    return_date: option.Option(date.Date),
    extension_count: Int,
  )
}

pub opaque type LoanId {
  LoanId(value: String)
}

fn new_id() -> LoanId {
  LoanId(uuid.v4())
}

pub fn new(
  book_id: book.BookId,
  user_id: user.UserId,
  current_date: date.Date,
  schedule_list: List(specify_schedule.SpecifySchedule),
) -> Result(Loan, String) {
  let due_date =
    current_date
    |> date.add_days(14)
    |> library_schedule.find_due_date(schedule_list)

  use due_date <- result.try(due_date)

  Loan(
    id: new_id(),
    book_id:,
    user_id:,
    loan_date: current_date,
    due_date:,
    return_date: option.None,
    extension_count: 0,
  )
  |> Ok()
}

// Getter functions for accessing opaque type fields
pub fn id_value(loan: Loan) -> String {
  loan.id.value
}

pub fn id_from_string(value: String) -> LoanId {
  LoanId(value)
}

fn is_overdue(loan: Loan, current_date: date.Date) -> Bool {
  date.compare(current_date, order.Gt, loan.due_date)
  && option.is_none(loan.return_date)
}

pub fn has_overdue(loans: List(Loan), current_date: date.Date) -> Bool {
  use loan <- list.any(loans)
  loan |> is_overdue(current_date)
}

pub fn is_loan_limit(loans: List(Loan)) -> Bool {
  list.length(loans) >= 10
}

pub fn return_book(loan: Loan, return_date: date.Date) -> Result(Loan, String) {
  case loan.return_date {
    option.Some(_) -> Error("すでに返却済です")
    option.None -> {
      let loan = Loan(..loan, return_date: option.Some(return_date))
      Ok(loan)
    }
  }
}

pub fn extend_loan(
  loan: Loan,
  current_date: date.Date,
  schedule_list: List(specify_schedule.SpecifySchedule),
) -> Result(Loan, String) {
  use validated_loan <- result.try(validate_extension_eligibility(loan, current_date))
  
  let new_due_date =
    loan.due_date
    |> date.add_days(14)
    |> library_schedule.find_due_date(schedule_list)

  use new_due_date <- result.try(new_due_date)

  let extended_loan = Loan(
    ..validated_loan,
    due_date: new_due_date,
    extension_count: validated_loan.extension_count + 1,
  )
  
  Ok(extended_loan)
}

fn validate_extension_eligibility(loan: Loan, current_date: date.Date) -> Result(Loan, String) {
  case loan.return_date {
    option.Some(_) -> Error("返却済みの貸出は延長できません")
    option.None -> {
      case loan.extension_count >= 1 {
        True -> Error("延長は1回までです")
        False -> {
          case is_overdue(loan, current_date) {
            True -> Error("延滞中の貸出は延長できません")
            False -> Ok(loan)
          }
        }
      }
    }
  }
}
