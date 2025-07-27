import gleam/option

import core/book/domain/book

pub type BookRepository {
  BookRepository(
    search: GetBooks,
    create: CreateBook,
    read: GetBook,
    update: UpdateBook,
    delete: DeleteBook,
    exists: CheckBookExists,
  )
}

pub type GetBooks =
  fn(SearchParams) -> List(book.Book)

pub type SearchParams {
  SearchParams(title: option.Option(String), author: option.Option(String))
}

pub type GetBook =
  fn(String) -> Result(book.Book, List(String))

pub type CreateBook =
  fn(book.Book) -> Result(Nil, List(String))

pub type CreateParams {
  CreateParams(title: option.Option(String), author: option.Option(String))
}

pub type UpdateBook =
  fn(book.Book) -> Result(Nil, List(String))

pub type DeleteBook =
  fn(String) -> Result(Nil, List(String))

pub type CheckBookExists =
  fn(String) -> Result(book.BookId, String)
