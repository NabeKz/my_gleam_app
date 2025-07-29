import gleam/option

import core/shared/services/validator
import shell/shared/lib/uuid

/// Domain Models
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

pub type BookStatus {
  Available
  OnLoan
  Reserved
  Maintenance
  Lost
}

pub type BookCondition {
  Excellent
  Good
  Fair
  Poor
  Damaged
}

/// BookStatusのヘルパー関数
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

/// BookConditionのヘルパー関数
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

/// 利用可能かどうかの判定
pub fn is_available(status: BookStatus) -> Bool {
  case status {
    Available -> True
    _ -> False
  }
}

/// Domain Logic
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
