import features/book/port/book_id
import features/loan/domain
import gleeunit
import gleeunit/should
import shared/date

pub fn main() {
  gleeunit.main()
}

pub fn date_test() {
  let book_id = book_id.new()
  let loan = domain.loan(book_id, date.from(#(2025, 7, 10)))
  let actual = loan.due_date |> date.to_string

  actual
  |> should.equal("2025-07-24")
}
