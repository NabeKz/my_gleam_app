import db/db
import db/migrate/a_create_tickets

pub fn main() {
  let conn = db.open("database.sqlite3")

  conn
  |> a_create_tickets.up()
  |> a_create_tickets.seed()
}
