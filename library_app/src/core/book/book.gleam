import gleam/option

import core/shared/services/validator
import shell/shared/lib/uuid

/// repository
pub type CheckBookExists =
  fn(String) -> Result(BookId, String)

/// get
pub type GetBooks =
  fn(SearchParams) -> List(Book)

pub type GetBook =
  fn(SearchParams) -> Result(Book, String)

pub type SearchParams {
  SearchParams(title: option.Option(String), author: option.Option(String))
}

/// create
pub type CreateBook =
  fn(Book) -> Result(Nil, List(String))

pub type CreateParams {
  CreateParams(title: option.Option(String), author: option.Option(String))
}

/// model
pub type Book {
  Book(id: BookId, title: BookTitle, author: BookAuthor)
}

pub opaque type BookId {
  BookId(value: String)
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

    Book(id: new_id(), title:, author:)
    |> validator.success()
  }
  validator.run(validated)
}

fn new_id() -> BookId {
  BookId(uuid.v4())
}

pub fn id_to_string(vo: BookId) -> String {
  vo.value
}

pub fn id_from_string(value: String) -> BookId {
  BookId(value)
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
