import gleam/dynamic/decode
import gleam/result

import core/book/book
import core/shared/helper/decoder

pub fn create_book_workflows(
  params: book.UnValidatedCreateParams,
  create_book: book.CreateBook,
) -> Result(Nil, List(String)) {
  validate(params)
  |> result.map(create_book)
  |> result.flatten()
}

fn validate(
  params: book.UnValidatedCreateParams,
) -> Result(book.ValidatedCreateParams, List(String)) {
  book.ValidatedCreateParams(params.title, params.author)
  |> Ok()
}

pub fn decode_create_params() -> decode.Decoder(book.UnValidatedCreateParams) {
  use title <- decoder.optional_field("title", decode.string)
  use author <- decoder.optional_field("author", decode.string)

  decode.success(book.UnValidatedCreateParams(title:, author:))
}
