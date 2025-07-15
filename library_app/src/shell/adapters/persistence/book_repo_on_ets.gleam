import gleam/result

import core/book/types/book
import core/book/types/book_id
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
    fn(it) { it.id |> book_id.to_string() },
  )
}

pub fn search_books(
  _create_params: book.SearchParams,
  conn: BookRepo,
) -> List(book.Book) {
  conn.all()
}

pub fn exits(id: String, conn: BookRepo) -> Result(book_id.BookId, String) {
  use book <- result.map(conn.get(id))
  book.id
}
