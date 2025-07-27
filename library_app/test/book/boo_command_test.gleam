import gleam/option
import gleeunit
import gleeunit/should

import core/book/application/book_command
import core/book/domain/book

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn books_success_test() {
  let actual =
    book_command.create_book_workflow(fn(_) { Ok(Nil) })(book.CreateParams(
      title: option.Some("a"),
      author: option.Some("a"),
    ))

  actual
  |> should.equal(Ok(Nil))
}

pub fn books_failure_test() {
  let actual =
    book_command.create_book_workflow(fn(_) { Ok(Nil) })(book.CreateParams(
      title: option.None,
      author: option.None,
    ))

  actual
  |> should.equal(Error(["title is required", "author is required"]))
}
