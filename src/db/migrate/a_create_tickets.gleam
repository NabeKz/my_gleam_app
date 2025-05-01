import sqlight

import app/ticket/domain.{TicketWriteModel}
import app/ticket/domain/ticket_status
import app/ticket/infra/ticket_repository_on_sqlite as repo

pub fn up(conn: sqlight.Connection) {
  let sql =
    "
  create table tickets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    description TEXT,
    status TEXT,
    created_at TEXT
  );
  "
  let assert Ok(Nil) = sqlight.exec(sql, conn)

  let assert Ok(Nil) =
    conn
    |> repo.create(TicketWriteModel(
      title: "hoge",
      description: "aaa",
      status: ticket_status.Open,
      created_at: "2025-05-01",
    ))

  let assert Ok(_) = conn |> repo.find(domain.ticket_id("2"))

  conn
}
