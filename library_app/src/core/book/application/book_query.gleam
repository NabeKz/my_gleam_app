import gleam/dynamic/decode
import gleam/result

import core/book/domain/book
import core/book/domain/book_repository
import core/shared/helper/decoder

pub type CheckBookExists =
  fn(String) -> Result(book.BookId, String)

pub type GetBookWorkflow =
  fn(String) -> Result(book.Book, List(String))

pub type GetBooksWorkflow =
  fn(book_repository.SearchParams) -> Result(List(book.Book), List(String))

///
pub fn compose_search_books(
  params: book_repository.SearchParams,
  get_books: book_repository.GetBooks,
) -> Result(List(book.Book), List(String)) {
  params
  |> validate()
  |> result.map(get_books)
}

fn validate(
  params: book_repository.SearchParams,
) -> Result(book_repository.SearchParams, List(String)) {
  params |> Ok()
}

pub fn generate_search_params() -> decode.Decoder(book_repository.SearchParams) {
  use title <- decoder.optional_field("title", decode.string)
  use author <- decoder.optional_field("author", decode.string)

  decode.success(book_repository.SearchParams(title:, author:))
}
