import gleam/dynamic/decode
import shared/db

pub type Journal {
  Journal(
    id: Int,
    aggregate_type: String,
    aggregate_id: String,
    version: Int,
    event_type: String,
    event: String,
    created_at: String,
  )
}

pub fn invoke(connection: db.Connection) {
  case
    db.query(
      "SELECT id, aggregate_type, aggregate_id, version, event_type, event, created_at FROM journals ORDER BY id",
      connection,
      decoder(),
    )
  {
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
      "INSERT INTO journals (aggregate_type, aggregate_id, version, event_type, event, created_at) VALUES ('account', 'counter-1', 1, 'account.deposited', 'credited', '2025-10-10T00:00:00Z');",
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
  use aggregate_id <- decode.field(2, decode.string)
  use version <- decode.field(3, decode.int)
  use event_type <- decode.field(4, decode.string)
  use event <- decode.field(5, decode.string)
  use created_at <- decode.field(6, decode.string)

  decode.success(Journal(
    id:,
    aggregate_type:,
    aggregate_id:,
    version:,
    event_type:,
    event:,
    created_at:,
  ))
}
