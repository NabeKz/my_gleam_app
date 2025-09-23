import gleam/dynamic/decode
import sqlight

pub type Connection {
  Connection(sqlight.Connection)
}

pub type Sql {
  Sql(value: String, args: List(sqlight.Value))
}

pub fn new() {
  let assert Ok(connection) = sqlight.open(":memory:")
  Connection(connection)
}

pub fn exec(connection: Connection) {
  let Connection(connection) = connection

  sqlight.exec("", connection)
}

pub fn query(connection: Connection, decoder: decode.Decoder(t)) {
  let Connection(connection) = connection

  sqlight.query("", connection, [], decoder)
}
