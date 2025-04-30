import sqlight

pub fn up(conn: sqlight.Connection) {
  let sql =
    "
  create table tickets (
    id TEXT,
    title TEXT,
    description TEXT,
    status TEXT,
    created_at TEXT
  );

  insert into tickets (
    id,
    title,
    description,
    status,
    created_at
  ) values (
    '1',
    'title',
    'description',
    'open',
    '2025-04-01'
  )
  "
  let assert Ok(Nil) = sqlight.exec(sql, conn)
  conn
}
