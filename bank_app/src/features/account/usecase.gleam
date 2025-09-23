import gleam/dynamic/decode
import shared/db

pub type Journal {
  Journal(id: Int, aggregate_type: String, event: String, created_at: String)
}

pub fn invoke(connection: db.Connection) {
  case db.query("SELECT * FROM journals", connection, decoder()) {
    Ok(row) -> Ok(row)
    Error(error) -> {
      echo error
      Error("ng")
    }
  }
}

pub fn exec(connection: db.Connection) {
  case
    db.query(
      "INSERT INTO journals (aggregate_type, event, created_at) VALUES ('a', 'c', '2025-10-10');",
      connection,
      decode.success(Nil),
    )
  {
    Ok(_) -> Ok("ok")
    Error(error) -> {
      echo error
      Error("ng")
    }
  }
}

fn decoder() -> decode.Decoder(Journal) {
  use id <- decode.field(0, decode.int)
  use aggregate_type <- decode.field(1, decode.string)
  use event <- decode.field(2, decode.string)
  use created_at <- decode.field(3, decode.string)

  decode.success(Journal(id:, aggregate_type:, event:, created_at:))
}
