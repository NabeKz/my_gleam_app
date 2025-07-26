import gleam/result

import core/book/book
import core/book/book_ports
import shell/shared/lib/ets

type BookRepo =
  ets.Conn(String, book.Book)

pub fn new() -> BookRepo {
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
}

pub fn search_books(
  _create_params: book_ports.SearchParams,
  conn: BookRepo,
) -> List(book.Book) {
  conn.all()
}

pub fn exits(id: String, conn: BookRepo) -> Result(book.BookId, String) {
  use book <- result.map(conn.get(id))
  book.id
}

pub fn create(book: book.Book, conn: BookRepo) -> Result(Nil, List(String)) {
  conn.create(#(book.id |> book.id_to_string(), book))
  |> result.map_error(fn(it) { [it] })
}
