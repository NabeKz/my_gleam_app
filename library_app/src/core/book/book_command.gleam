import gleam/dynamic/decode
import gleam/list
import gleam/option
import gleam/result

import core/book/book
import core/shared/helper/decoder
import core/shared/services/validator

pub fn create_book_workflows(
  params: book.CreateParams,
  create_book: book.CreateBook,
) -> Result(Nil, List(String)) {
  validate(params)
  |> result.map(create_book)
  |> result.flatten()
}

fn validate(params: book.CreateParams) -> Result(book.Book, List(String)) {
  let title = option.unwrap(params.title, "")
  let author = option.unwrap(params.author, "")

  book.new(title, author)
  |> result.map_error(fn(it) { list.map(it, validator.to_string) })
}

pub fn decode_create_params() -> decode.Decoder(book.CreateParams) {
  use title <- decoder.optional_field("title", decode.string)
  use author <- decoder.optional_field("author", decode.string)

  decode.success(book.CreateParams(title:, author:))
}
