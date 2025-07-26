import gleam/dynamic/decode
import gleam/result

import core/book/book
import core/book/book_ports
import core/shared/helper/decoder

pub fn compose_search_books(
  params: book_ports.SearchParams,
  get_books: book_ports.GetBooks,
) -> Result(List(book.Book), List(String)) {
  params
  |> validate()
  |> result.map(get_books)
}

fn validate(
  params: book_ports.SearchParams,
) -> Result(book_ports.SearchParams, List(String)) {
  params |> Ok()
}

pub fn generate_search_params() -> decode.Decoder(book_ports.SearchParams) {
  use title <- decoder.optional_field("title", decode.string)
  use author <- decoder.optional_field("author", decode.string)

  decode.success(book_ports.SearchParams(title:, author:))
}
