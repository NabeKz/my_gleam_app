import lib/db

import db/migrate/a_create_tickets

pub fn main() {
  use conn <- db.with_connection("database.sqlite3")

  conn
  |> a_create_tickets.up()
  |> a_create_tickets.seed()
}
