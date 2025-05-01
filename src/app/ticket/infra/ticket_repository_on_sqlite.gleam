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
