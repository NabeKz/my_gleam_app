import gleam/dynamic/decode
import gleam/int
import gleam/option
import gleam/string

import app/features/ticket/domain
import app/features/ticket/domain/ticket_status
import lib/db

const table_name = "tickets"

pub fn list(
  conn: db.Conn,
  params: domain.ValidateSearchParams,
) -> List(domain.Ticket) {
  let sql = "select * from " <> table_name
  let where = []
  let where = case params.title {
    option.Some("") -> where
    option.Some(_) -> ["title = ?", ..where]
    option.None -> where
  }
  let where = case params.status {
    option.Some(_) -> ["status = ?", ..where]
    option.None -> where
  }
  let sql = case where {
    [] -> sql
    _ -> sql <> " where " <> string.join(where, " and ")
  }
  let sql = sql <> ";"
  let values = case params.title {
    option.Some("") -> []
    option.Some(value) -> [value |> db.string()]
    option.None -> []
  }
  let result = db.query(sql, conn, values, decoder())
  case result {
    Ok(value) -> value
    Error(error) -> {
      echo error
      []
    }
  }
}

pub fn create(conn: db.Conn, item: domain.TicketWriteModel) {
  let sql = "insert into " <> table_name
  let sql = sql <> "
    (
      title,
      description,
      status,
      created_at 
    ) values ("

  let sql =
    sql
    <> [
      item.title,
      item.description,
      item.status |> ticket_status.to_string,
      item.created_at,
    ]
    |> db.escape()
    <> ");"

  db.exec(sql, conn)
}

pub fn find(
  conn: db.Conn,
  id: domain.TicketId,
) -> Result(domain.Ticket, db.ErrorMessage) {
  let sql = "select * from " <> table_name <> " "
  let sql = sql <> "
    where id = ?
    limit 1;
  "

  let result =
    db.query(sql, conn, [id |> domain.decode |> db.placeholder], decoder())

  result |> db.handle_find_result
}

pub fn delete(conn: db.Conn, id: domain.TicketId) -> Result(Nil, String) {
  let sql = "delete from " <> table_name <> "where id = ?"
  let result = db.query(sql, conn, [id |> db.placeholder], decode.success(Nil))

  case result {
    Ok(_) -> Ok(Nil)
    Error(error) -> Error(error.message)
  }
}

fn id_decoder(value: Int) -> domain.TicketId {
  value |> int.to_string |> domain.ticket_id
}

// TODO: handling
fn status_decoder(value: String) -> ticket_status.TicketStatus {
  let assert Ok(status) = value |> ticket_status.from_string
  status
}

fn decoder() -> decode.Decoder(domain.Ticket) {
  use id <- decode.field(0, decode.int |> decode.map(id_decoder))
  use title <- decode.field(1, decode.string)
  use description <- decode.field(2, decode.string)
  use status <- decode.field(3, decode.string |> decode.map(status_decoder))
  use created_at <- decode.field(4, decode.string)

  decode.success(
    domain.Ticket(id:, title:, description:, status:, created_at:, replies: []),
  )
}
