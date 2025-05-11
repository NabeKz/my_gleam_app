import lib/db

pub fn up(conn: db.Conn) {
  let sql =
    "
  create table users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    status TEXT,
    created_at TEXT
  );
  "
  let assert Ok(Nil) = db.exec(sql, conn)

  conn
}
