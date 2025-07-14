import gleam/dynamic/decode
import gleam/option
import gleam/result

import features/book/port/book_id
import shared/validator

/// events
pub type GetBooks =
  fn(SearchParams) -> List(Book)

pub type SearchParams {
  SearchParams(title: option.Option(String), author: option.Option(String))
}

pub type CreateBook =
  fn() -> Result(Nil, String)

pub type SearchBooks =
  fn(CreateParams) -> Result(List(Book), List(decode.DecodeError))

pub type CheckBookExists =
  fn(book_id.BookId) -> Bool

pub type CreateParams =
  Result(SearchParams, List(decode.DecodeError))

pub fn compose_search_books(
  create_params: CreateParams,
  get_books: GetBooks,
) -> Result(List(Book), List(decode.DecodeError)) {
  use params <- result.try(create_params)

  get_books(params) |> Ok
}

/// model
pub type Book {
  Book(id: book_id.BookId, title: BookTitle, author: BookAuthor)
}

pub type UnValidatedBook {
  UnValidatedBook(title: option.Option(String), author: option.Option(String))
}

pub opaque type BookTitle {
  BookTitle(value: String)
}

pub opaque type BookAuthor {
  BookAuthor(value: String)
}

pub fn new(
  title: String,
  author: String,
) -> Result(Book, List(validator.ValidateError)) {
  let validated = {
    use title <- validator.field(validate_title(title))
    use author <- validator.field(validate_author(author))

    Book(id: book_id.new(), title:, author:)
    |> validator.success()
  }
  validator.run(validated)
}

fn validate_title(title: String) -> validator.Validator(BookTitle) {
  validator.wrap("title", title)
  |> validator.required_string()
  |> validator.less_than(200)
  |> validator.map(BookTitle)
}

fn validate_author(value: String) -> validator.Validator(BookAuthor) {
  validator.wrap("author", value)
  |> validator.required_string()
  |> validator.less_than(200)
  |> validator.map(BookAuthor)
}
