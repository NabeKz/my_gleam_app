import gleam/option

import core/shared/services/validator
import shell/shared/lib/uuid

/// 
pub type Book {
  Book(id: BookId, title: BookTitle, author: BookAuthor)
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

/// 
pub opaque type BookId {
  BookId(value: String)
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

///
pub type BookStatus {
  Available
  OnLoan
  Reserved
  Maintenance
  Lost
}

pub fn status_to_string(status: BookStatus) -> String {
  case status {
    Available -> "available"
    OnLoan -> "on_loan"
    Reserved -> "reserved"
    Maintenance -> "maintenance"
    Lost -> "lost"
  }
}

pub fn status_from_string(value: String) -> Result(BookStatus, Nil) {
  case value {
    "available" -> Ok(Available)
    "on_loan" -> Ok(OnLoan)
    "reserved" -> Ok(Reserved)
    "maintenance" -> Ok(Maintenance)
    "lost" -> Ok(Lost)
    _ -> Error(Nil)
  }
}

pub fn is_available(status: BookStatus) -> Bool {
  status == Available
}

pub type BookCondition {
  Excellent
  Good
  Fair
  Poor
  Damaged
}

pub fn condition_to_string(condition: BookCondition) -> String {
  case condition {
    Excellent -> "excellent"
    Good -> "good"
    Fair -> "fair"
    Poor -> "poor"
    Damaged -> "damaged"
  }
}

pub fn condition_from_string(value: String) -> Result(BookCondition, Nil) {
  case value {
    "excellent" -> Ok(Excellent)
    "good" -> Ok(Good)
    "fair" -> Ok(Fair)
    "poor" -> Ok(Poor)
    "damaged" -> Ok(Damaged)
    _ -> Error(Nil)
  }
}

/// BookTitle型とその関連関数
pub opaque type BookTitle {
  BookTitle(value: String)
}

fn validate_title(title: String) -> validator.Validator(BookTitle) {
  validator.wrap("title", title)
  |> validator.required_string()
  |> validator.less_than(200)
  |> validator.map(BookTitle)
}

pub fn title_value(book: Book) -> String {
  book.title.value
}

/// BookAuthor型とその関連関数
pub opaque type BookAuthor {
  BookAuthor(value: String)
}

fn validate_author(value: String) -> validator.Validator(BookAuthor) {
  validator.wrap("author", value)
  |> validator.required_string()
  |> validator.less_than(200)
  |> validator.map(BookAuthor)
}

pub fn author_value(book: Book) -> String {
  book.author.value
}

pub fn update(
  existing_book: Book,
  title: option.Option(String),
  author: option.Option(String),
) -> Result(Book, List(validator.ValidateError)) {
  let title_value = option.unwrap(title, title_value(existing_book))
  let author_value = option.unwrap(author, author_value(existing_book))

  let validated = {
    use title <- validator.field(validate_title(title_value))
    use author <- validator.field(validate_author(author_value))

    Book(id: existing_book.id, title:, author:)
    |> validator.success()
  }
  validator.run(validated)
}

/// ReadModel for Query operations
pub type BookReadModel {
  BookReadModel(id: BookId, title: String, author: String)
}

pub fn to_read_model(book: Book) -> BookReadModel {
  BookReadModel(
    id: book.id,
    title: title_value(book),
    author: author_value(book),
  )
}
