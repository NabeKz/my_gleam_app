import gleam/result

import features/book/domain
import features/book/port/book_id
import shared/lib/ets

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

pub fn exits(id: String, conn: BookRepo) -> Bool {
  conn.get(id) |> result.is_ok()
}
