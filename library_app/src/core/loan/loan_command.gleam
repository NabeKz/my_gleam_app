import gleam/bool
import gleam/dynamic/decode
import gleam/option
import gleam/result

import core/book/book
import core/loan/loan
import core/shared/helper/decoder
import core/shared/types/date
import core/shared/types/user

pub type CreateLoan =
  fn(user.User, String) -> Result(Nil, String)

pub type ReturnLoan =
  fn(String) -> Result(loan.Loan, String)

// Command functions
pub fn create_loan_workflow(
  current_date: fn() -> date.Date,
  check_book_exists: book.CheckBookExists,
  get_loans: loan.GetLoans,
  save_loan: loan.SaveLoan,
) -> CreateLoan {
  fn(user: user.User, book_id: String) -> Result(Nil, String) {
    use book_id <- result.try(check_book_exists(book_id))

    let loans =
      loan.GetLoansParams(option.None)
      |> get_loans()

    use <- bool.guard(
      loans |> loan.has_overdue(current_date()),
      Error("延滞を解消してください"),
    )

    use <- bool.guard(loans |> loan.is_loan_limit(), Error("貸出上限です"))

    book_id
    |> loan.new(user.id, current_date())
    |> save_loan()
  }
}

pub fn create_loan_decoder() -> decode.Decoder(loan.CreateLoanParams) {
  use book_id <- decoder.required_field("book_id", decode.string)
  decode.success(loan.CreateLoanParams(book_id))
}

// Update functions
pub fn return_book_workflow(
  current_date: date.GetDate,
  get_loan_by_book_id: loan.GetLoanByBookId,
  update_loan: loan.UpdateLoan,
) -> ReturnLoan {
  fn(book_id: String) -> Result(loan.Loan, String) {
    use loan <- result.try(
      book_id |> book.id_from_string() |> get_loan_by_book_id(),
    )

    loan.return_book(loan, current_date())
    |> result.map(update_loan)
    |> result.flatten()
  }
}
