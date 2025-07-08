import gleam/dynamic/decode
import gleam/result

import features/book/converter
import features/book/model
import features/book/types

pub type GetBooks =
  fn(types.SearchParams) -> List(model.Book)

pub type SearchBooks =
  fn(List(#(String, String))) ->
    Result(List(model.Book), List(decode.DecodeError))

pub fn search_books_workflow(
  params: List(#(String, String)),
  get_books: GetBooks,
) -> Result(List(model.Book), List(decode.DecodeError)) {
  use params <- result.try(converter.to_search_params(params))
  get_books(params) |> Ok
}
