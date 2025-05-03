import gleam/dynamic/decode
import gleam/int

import app/ticket/domain
import app/ticket/domain/ticket_status
import db/db

const table_name = "tickets"

pub fn select(conn: db.Conn) {
  let sql = "select * from  " <> table_name <> " limit 100"
  db.query(sql, conn, [], decoder())
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
