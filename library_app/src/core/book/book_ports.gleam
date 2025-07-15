import gleam/option

import core/book/book

pub type CheckBookExists =
  fn(String) -> Result(book.BookId, String)

pub type GetBooks =
  fn(SearchParams) -> List(book.Book)

pub type SearchParams {
  SearchParams(title: option.Option(String), author: option.Option(String))
}

pub type CreateBook =
  fn() -> Result(Nil, String)

pub type UnValidatedBook {
  UnValidatedBook(title: option.Option(String), author: option.Option(String))
}

pub type GetBooksWorkflow =
  fn(book.SearchParams) -> Result(List(book.Book), List(String))
