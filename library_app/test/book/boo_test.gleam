import core/book/book
import core/book/book_command
import gleam/option
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn books_success_test() {
  let actual =
    book_command.create_book_workflows(
      book.CreateParams(title: option.Some("a"), author: option.Some("a")),
      fn(_) { Ok(Nil) },
    )

  actual
  |> should.equal(Ok(Nil))
}

pub fn books_failure_test() {
  let actual =
    book_command.create_book_workflows(
      book.CreateParams(title: option.None, author: option.None),
      fn(_) { Ok(Nil) },
    )

  actual
  |> should.equal(Error(["title is required", "author is required"]))
}
