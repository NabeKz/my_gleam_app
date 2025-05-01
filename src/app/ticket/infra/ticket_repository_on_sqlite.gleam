import gleam/dynamic/decode
import sqlight

import app/ticket/domain
import app/ticket/domain/ticket_status
import db/db

const table_name = "tickets"

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

pub fn find(conn: db.Conn, id: domain.TicketId) {
  let sql = "select * from " <> table_name <> " "
  let sql = sql <> "
    where id = ?
    limit 1;
  "

  db.query(sql, conn, [id |> domain.decode |> sqlight.text], decoder())
}

fn decoder() -> decode.Decoder(domain.Ticket) {
  use id <- decode.field(0, decode.string)
  let id = id |> domain.ticket_id

  use title <- decode.field(1, decode.string)
  use description <- decode.field(2, decode.string)
  use status <- decode.field(3, decode.string)

  let assert Ok(status) = status |> ticket_status.from_string

  use created_at <- decode.field(4, decode.string)

  decode.success(
    domain.Ticket(id:, title:, description:, status:, created_at:, replies: []),
  )
}
