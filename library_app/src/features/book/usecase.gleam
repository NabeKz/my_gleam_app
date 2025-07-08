import gleam/dynamic/decode
import gleam/result

import features/book/model
import features/book/types

pub type CreateParams =
  Result(types.SearchParams, List(decode.DecodeError))

pub type GetBooks =
  fn(types.SearchParams) -> List(model.Book)

pub type SearchBooks =
  fn(CreateParams) -> Result(List(model.Book), List(decode.DecodeError))

pub fn compose_search_books(
  create_params: CreateParams,
  get_books: GetBooks,
) -> Result(List(model.Book), List(decode.DecodeError)) {
  use params <- result.try(create_params)

  get_books(params) |> Ok
}
