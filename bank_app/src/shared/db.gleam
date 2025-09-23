import gleam/dynamic/decode
import shared/ffi/os
import sqlight

pub type Connection {
  Connection(sqlight.Connection)
}

pub type Sql {
  Sql(value: String, args: List(sqlight.Value))
}

pub fn new() {
  let assert Ok(basepath) = os.get_cwd()
  let db_path = basepath <> "/db/database.sqlite3"

  let assert Ok(connection) = sqlight.open(db_path)
  Connection(connection)
}

pub fn exec(sql: String, connection: Connection) {
  let Connection(connection) = connection

  sqlight.exec(sql, connection)
}

pub fn query(sql: String, connection: Connection, decoder: decode.Decoder(t)) {
  let Connection(connection) = connection

  sqlight.query(sql, connection, [], decoder)
}
