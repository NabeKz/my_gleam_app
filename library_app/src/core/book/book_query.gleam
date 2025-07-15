import gleam/dynamic/decode
import gleam/result

import core/book/book
import core/shared/helper/decoder

pub fn compose_search_books(
  params: book.SearchParams,
  get_books: book.GetBooks,
) -> Result(List(book.Book), List(String)) {
  params
  |> validate()
  |> result.map(get_books)
}

fn validate(
  params: book.SearchParams,
) -> Result(book.SearchParams, List(String)) {
  params |> Ok()
}

pub fn generate_search_params() -> decode.Decoder(book.SearchParams) {
  use title <- decoder.optional_field("title", decode.string)
  use author <- decoder.optional_field("author", decode.string)

  decode.success(book.SearchParams(title:, author:))
}
