import gleam/option
import gleam/result

import core/book/types/book_id
import core/shared/services/validator

/// events
pub type GetBooks =
  fn(SearchParams) -> List(Book)

pub type SearchParams {
  SearchParams(title: option.Option(String), author: option.Option(String))
}

pub type CreateBook =
  fn() -> Result(Nil, String)

pub type SearchBooks =
  fn(SearchParams) -> Result(List(Book), List(String))

pub type CheckBookExists =
  fn(String) -> Result(book_id.BookId, String)

pub fn compose_search_books(
  params: SearchParams,
  get_books: GetBooks,
) -> Result(List(Book), List(String)) {
  params
  |> validate()
  |> result.map(get_books)
}

fn validate(params: SearchParams) -> Result(SearchParams, List(String)) {
  params |> Ok()
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

pub fn title_value(book: Book) -> String {
  book.title.value
}

pub fn author_value(book: Book) -> String {
  book.author.value
}
