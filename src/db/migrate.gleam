import sqlight

import db/migrate/a_create_tickets

pub fn main() {
  use conn <- sqlight.with_connection("database.sqlite3")

  conn
  |> a_create_tickets.up()
}
