import gleam/dynamic/decode
import gleam/list
import gleam/option
import gleam/result

import core/book/book
import core/book/book_ports
import core/shared/helper/decoder
import core/shared/services/validator

/// create
pub fn create_book_workflow(
  create_book: book_ports.CreateBook,
) -> book_ports.CreateBookWorkflow {
  fn(params: book_ports.CreateParams) {
    validate(params)
    |> result.map(create_book)
    |> result.flatten()
  }
}

fn validate(params: book_ports.CreateParams) -> Result(book.Book, List(String)) {
  let title = option.unwrap(params.title, "")
  let author = option.unwrap(params.author, "")

  book.new(title, author)
  |> result.map_error(fn(it) { list.map(it, validator.to_string) })
}

pub fn decode_create_params() -> decode.Decoder(book_ports.CreateParams) {
  use title <- decoder.optional_field("title", decode.string)
  use author <- decoder.optional_field("author", decode.string)

  decode.success(book_ports.CreateParams(title:, author:))
}

/// update
pub fn update_book_workflow(
  get_book: book_ports.GetBook,
  update_book: book_ports.UpdateBook,
) -> book_ports.UpdateBookWorkflow {
  fn(book_id: String, params: book_ports.UpdateParams) {
    use existing_book <- result.try(book_id |> get_book())
    use updated_book <- result.try(
      book.update(existing_book, params.title, params.author)
      |> result.map_error(list.map(_, validator.to_string)),
    )

    update_book(updated_book)
  }
}

pub fn decode_update_params() -> decode.Decoder(book_ports.UpdateParams) {
  use title <- decoder.optional_field("title", decode.string)
  use author <- decoder.optional_field("author", decode.string)

  decode.success(book_ports.UpdateParams(title:, author:))
}

/// delete
pub fn delete_book_workflow(
  delete_book: book_ports.DeleteBook,
) -> book_ports.DeleteBookWorkflow {
  fn(book_id) { delete_book(book_id) }
}
