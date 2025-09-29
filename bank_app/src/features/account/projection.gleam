import gleam/dynamic/decode
import shared/db
import sqlight

pub type ReadModel {
  ReadModel(id: Int)
}

pub fn apply(connection: db.Connection) {
  db.query_with(
    db.Sql(statement: "select * fron journals where event_type = ?", args: [
      sqlight.text("hogehoge"),
    ]),
    connection,
    {
      use id <- decode.field(0, decode.int)
      decode.success(ReadModel(id))
    },
  )
}
