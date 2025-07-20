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
  fn(user.User, loan.CreateLoanParams) -> Result(Nil, String)

// Command functions
pub fn create_loan_workflow(
  current_date: fn() -> date.Date,
  check_book_exists: book.CheckBookExists,
  get_loans: loan.GetLoans,
  save_loan: loan.SaveLoan,
) -> CreateLoan {
  fn(user: user.User, params: loan.CreateLoanParams) -> Result(Nil, String) {
    use book_id <- result.try(check_book_exists(params.book_id))

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
