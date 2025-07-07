import features/book/model
import gleam/option

pub type GetBooks =
  fn() -> List(model.Book)

pub type SearchBooks =
  fn(SearchParams) -> List(model.Book)

pub type SearchParams {
  SearchParams(title: option.Option(String), author: option.Option(String))
}

pub fn search_books(
  _params: SearchParams,
  get_books: GetBooks,
) -> List(model.Book) {
  get_books()
}
