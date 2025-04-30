import gleam/string

import app/ticket/domain
import app/ticket/domain/ticket_status
import db/db

const table_name = "tickets"

pub fn create(conn: db.Conn, item: domain.TicketWriteModel) {
  let sql =
    "insert into "
    <> table_name
    |> string.append("title" <> item.title)
    |> string.append("status" <> ticket_status.to_string(item.status))
    |> string.append(";")

  let assert Ok(Nil) = db.exec(sql, conn)
}
