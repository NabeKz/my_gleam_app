////

import gleam/dynamic/decode
import gleam/list
import gleam/option
import gleam/result

import core/book/domain/book
import core/shared/helper/decoder
import core/shared/services/validator

pub type CreateBookWorkflow =
  fn(book.CreateParams) -> Result(Nil, List(String))

pub type UpdateBookWorkflow =
  fn(String, UpdateParams) -> Result(Nil, List(String))

pub type UpdateParams {
  UpdateParams(title: option.Option(String), author: option.Option(String))
}

pub type DeleteBookWorkflow =
  fn(String) -> Result(Nil, List(String))

///
/// create
pub fn create_book_workflow(create_book: book.CreateBook) -> CreateBookWorkflow {
  fn(params) {
    validate(params)
    |> result.map(create_book)
    |> result.flatten()
  }
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

/// update
pub fn update_book_workflow(
  get_book: book.GetBook,
  update_book: book.UpdateBook,
) -> UpdateBookWorkflow {
  fn(book_id: String, params: UpdateParams) {
    use existing_book <- result.try(book_id |> get_book())
    use updated_book <- result.try(
      book.update(existing_book, params.title, params.author)
      |> result.map_error(list.map(_, validator.to_string)),
    )

    update_book(updated_book)
  }
}

pub fn decode_update_params() -> decode.Decoder(UpdateParams) {
  use title <- decoder.optional_field("title", decode.string)
  use author <- decoder.optional_field("author", decode.string)

  decode.success(UpdateParams(title:, author:))
}

/// delete
pub fn delete_book_workflow(delete_book: book.DeleteBook) -> DeleteBookWorkflow {
  fn(book_id) { delete_book(book_id) }
}
