import gleam/result

import core/book/types/book as domain
import core/book/types/book_id
import shell/shared/lib/ets

type BookRepo =
  ets.Conn(String, domain.Book)

pub fn new() -> BookRepo {
  ets.conn(
    "loans",
    [
      domain.new("hoge", "aaa"),
      domain.new("fuga", "bbb"),
      domain.new("piyo", "ccc"),
    ]
      |> result.values(),
    fn(it) { it.id |> book_id.to_string() },
  )
}

pub fn exits(id: String, conn: BookRepo) -> Result(book_id.BookId, String) {
  use book <- result.map(conn.get(id))
  book.id
}
