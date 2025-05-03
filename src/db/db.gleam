import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import gleam/string
import sqlight

pub opaque type Conn {
  Conn(value: sqlight.Connection)
}

pub type Error =
  sqlight.Error

pub type ErrorMessage {
  NotFound
  MultiRecordFound
  SqlError(message: String)
}

pub fn exec(sql: String, conn: Conn) -> Result(Nil, Error) {
  sqlight.exec(sql, conn.value)
}

pub fn query(
  sql: String,
  conn: Conn,
  values: List(sqlight.Value),
  decoder: decode.Decoder(a),
) -> Result(List(a), Error) {
  sqlight.query(sql, conn.value, values, decoder)
}

pub fn open(name: String) -> Conn {
  use conn <- sqlight.with_connection(name)
  Conn(conn)
}

pub fn placeholder(value: a) -> sqlight.Value {
  let assert Ok(value) = dynamic.from(value) |> decode.run(decode.string)
  // let value = result.map(value |>)
  sqlight.text(value)
}

pub fn escape(values: List(String)) -> String {
  list.map(values, fn(it) { "'" <> it <> "'" })
  |> string.join(",")
}

pub fn handle_find_result(
  result: Result(List(a), Error),
) -> Result(a, ErrorMessage) {
  case result {
    Ok([first]) -> Ok(first)
    Ok([]) -> Error(NotFound)
    Ok([_, ..]) -> Error(MultiRecordFound)
    Error(err) -> Error(SqlError(err.message))
  }
}
