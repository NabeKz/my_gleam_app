import core/book/types/book
import gleam/dynamic/decode
import gleam/option
import gleam/result

import core/book/types/book_id
import core/shared/helper/decoder

pub type GetBooks =
  fn(SearchParams) -> List(book.Book)

pub type SearchParams {
  SearchParams(title: option.Option(String), author: option.Option(String))
}

pub type CreateBook =
  fn() -> Result(Nil, String)

pub type SearchBooks =
  fn(SearchParams) -> Result(List(book.Book), List(String))

pub type CheckBookExists =
  fn(String) -> Result(book_id.BookId, String)

pub fn compose_search_books(
  params: SearchParams,
  get_books: GetBooks,
) -> Result(List(book.Book), List(String)) {
  params
  |> validate()
  |> result.map(get_books)
}

fn validate(params: SearchParams) -> Result(SearchParams, List(String)) {
  params |> Ok()
}

pub fn to_search_params() -> decode.Decoder(book.SearchParams) {
  use title <- decoder.optional_field("title", decode.string)
  use author <- decoder.optional_field("author", decode.string)

  decode.success(book.SearchParams(title:, author:))
}
