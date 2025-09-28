import gleam/dynamic/decode
import gleam/result
import shared/ffi/os
import sqlight

pub type Connection {
  Connection(sqlight.Connection)
}

pub type Sql {
  Sql(statement: String, args: List(sqlight.Value))
}

pub fn new() {
  let assert Ok(basepath) = os.get_cwd()
  let db_path = basepath <> "/db/database.sqlite3"

  let assert Ok(connection) = sqlight.open(db_path)
  Connection(connection)
}

pub fn exec(statement: String, connection: Connection) {
  let Connection(connection) = connection

  let _ = sqlight.exec(statement, connection)
}

pub fn exec_with(sql: Sql, connection: Connection) {
  let Connection(connection) = connection
  let Sql(statement, args) = sql

  let _ = sqlight.query(statement, connection, args, decode.success(Nil))
}

pub fn exec_with_result(
  sql: Sql,
  connection: Connection,
) -> Result(Nil, sqlight.Error) {
  let Connection(connection) = connection
  let Sql(statement, args) = sql

  sqlight.query(statement, connection, args, decode.success(Nil))
  |> result.map(fn(_) { Nil })
}

pub fn query(sql: String, connection: Connection, decoder: decode.Decoder(t)) {
  query_with(Sql(sql, []), connection, decoder)
}

pub fn query_with(
  sql: Sql,
  connection: Connection,
  decoder: decode.Decoder(t),
) {
  let Connection(connection) = connection
  let Sql(statement, args) = sql

  sqlight.query(statement, connection, args, decoder)
}

pub fn sql(statement: String, args: List(sqlight.Value)) -> Sql {
  Sql(statement, args)
}
