import gleam/result

import core/book/book
import core/book/book_ports
import core/book/ports/book_repository
import shell/shared/lib/ets

type BookRepo =
  ets.Conn(String, book.Book)

type Command =
  Result(Nil, List(String))

pub fn new() -> book_repository.BookRepository {
  let conn =
    ets.conn(
      [
        book.new("hoge", "aaa"),
        book.new("fuga", "bbb"),
        book.new("piyo", "ccc"),
        book.new("foo", "ddd"),
        book.new("bar", "ddd"),
      ]
        |> result.values(),
      fn(it) { it.id |> book.id_to_string() },
    )
  book_repository.BookRepository(
    search: search_books(_, conn),
    create: create(_, conn),
    read: read(_, conn),
    update: update(_, conn),
    delete: delete(_, conn),
    exists: exits(_, conn),
  )
}

pub fn search_books(
  _create_params: book_ports.SearchParams,
  conn: BookRepo,
) -> List(book.Book) {
  conn.all()
}

pub fn create(book: book.Book, conn: BookRepo) -> Command {
  conn.create(#(book.id |> book.id_to_string(), book))
  |> result.map_error(fn(it) { [it] })
}

pub fn read(book_id: String, conn: BookRepo) -> Result(book.Book, List(String)) {
  conn.get(book_id)
  |> result.map_error(fn(it) { [it] })
}

pub fn update(book: book.Book, conn: BookRepo) -> Command {
  conn.update(#(book.id |> book.id_to_string(), book))
}

pub fn delete(book_id: String, conn: BookRepo) -> Command {
  conn.delete(book_id)
  |> result.map_error(fn(it) { [it] })
}

pub fn exits(id: String, conn: BookRepo) -> Result(book.BookId, String) {
  case conn.get(id) {
    Ok(book) -> Ok(book.id)
    Error(error) -> Error(error)
  }
}
