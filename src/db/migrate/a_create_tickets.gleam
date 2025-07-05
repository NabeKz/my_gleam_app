import app/features/ticket/domain.{TicketWriteModel}
import app/features/ticket/domain/ticket_status
import app/features/ticket/infra/ticket_repository_on_sqlite as repo
import lib/db

pub fn up(conn: db.Conn) {
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
  let assert Ok(Nil) = db.create(sql, conn)

  conn
}

pub fn seed(conn: db.Conn) {
  let assert Ok(Nil) =
    conn
    |> repo.create(TicketWriteModel(
      title: "hoge",
      description: "aaa",
      status: ticket_status.Open,
      created_at: "2025-05-01",
    ))
  let assert Ok(Nil) =
    conn
    |> repo.create(TicketWriteModel(
      title: "fuga",
      description: "bbb",
      status: ticket_status.Progress,
      created_at: "2025-05-02",
    ))
  let assert Ok(Nil) =
    conn
    |> repo.create(TicketWriteModel(
      title: "piyo",
      description: "ccc",
      status: ticket_status.Close,
      created_at: "2025-05-03",
    ))
}
