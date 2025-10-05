import gleam/dynamic/decode
import gleam/result
import sqlight

pub type Connection {
  Connection(sqlight.Connection)
}

pub type Sql {
  Sql(statement: String, args: List(sqlight.Value))
}

pub fn new(path: String) {
  let assert Ok(connection) = sqlight.open(path)
  Connection(connection)
}

pub fn exec_with(sql: Sql, connection: Connection) -> Result(Nil, sqlight.Error) {
  let Connection(connection) = connection
  let Sql(statement, args) = sql

  sqlight.query(statement, connection, args, decode.success(Nil))
  |> result.map(fn(_) { Nil })
}

pub fn query(sql: String, connection: Connection, decoder: decode.Decoder(t)) {
  query_with(Sql(sql, []), connection, decoder)
}

pub fn query_with(sql: Sql, connection: Connection, decoder: decode.Decoder(t)) {
  let Connection(connection) = connection
  let Sql(statement, args) = sql

  sqlight.query(statement, connection, args, decoder)
}

pub fn sql(statement: String, args: List(sqlight.Value)) -> Sql {
  Sql(statement, args)
}
