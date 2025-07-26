import gleam/option

import core/book/book

pub type CheckBookExists =
  fn(String) -> Result(book.BookId, String)

pub type GetBooks =
  fn(SearchParams) -> List(book.Book)

pub type SearchParams {
  SearchParams(title: option.Option(String), author: option.Option(String))
}

pub type GetBooksWorkflow =
  fn(SearchParams) -> Result(List(book.Book), List(String))

/// create
pub type CreateBook =
  fn(book.Book) -> Result(Nil, List(String))

pub type CreateParams {
  CreateParams(title: option.Option(String), author: option.Option(String))
}

pub type CreateBookWorkflow =
  fn(CreateParams) -> Result(Nil, List(String))

/// update
pub type UpdateBook =
  fn(book.Book) -> Result(Nil, List(String))

pub type UpdateBookWorkflow =
  fn() -> Result(Nil, List(String))

/// delete
pub type DeleteBook =
  fn(String) -> Result(Nil, List(String))

pub type DeleteBookWorkflow =
  fn(String) -> Result(Nil, List(String))
