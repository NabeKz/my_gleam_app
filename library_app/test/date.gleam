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
  let actual = domain.loan(book_id).due_date |> date.to_string

  actual
  |> should.equal("2025-07-24")
}
