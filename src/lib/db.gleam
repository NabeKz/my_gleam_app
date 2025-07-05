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

pub fn create(sql: String, conn: Conn) -> Result(Nil, Error) {
  sqlight.exec(sql, conn.value)
}

pub fn exec(
  sql: String,
  conn: Conn,
  values: List(sqlight.Value),
) -> Result(Nil, Error) {
  let result = sqlight.query(sql, conn.value, values, decode.success(Nil))
  case result {
    Ok(_) -> Ok(Nil)
    Error(error) -> Error(error)
  }
}

pub fn insert_with_values(
  table_name: String,
  values: List(#(String, sqlight.Value)),
) -> #(String, List(sqlight.Value)) {
  let #(columns, values) = list.unzip(values)
  let columns = columns |> string.join(",")
  let placeholders = list.repeat("?", list.length(values)) |> string.join(",")
  let sql =
    "insert into "
    <> table_name
    <> " ("
    <> columns
    <> ") values ("
    <> placeholders
    <> ")"

  #(sql, values)
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
  let assert Ok(conn) = sqlight.open(name)
  Conn(conn)
}

pub fn with_connection(name: String, f: fn(Conn) -> a) {
  let conn = open(name)
  let value = f(conn)
  let assert Ok(Nil) = sqlight.close(conn.value)
  value
}

pub fn transaction(conn: Conn) {
  let _ = sqlight.exec("begin transaction", conn.value)
  let _ = sqlight.exec("commit transaction", conn.value)
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

pub const string = sqlight.text
