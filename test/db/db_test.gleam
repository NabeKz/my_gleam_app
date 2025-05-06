import app/features/ticket/domain
import gleeunit
import gleeunit/should

import app/features/ticket/infra/ticket_repository_on_sqlite as repo
import lib/db

pub fn main() {
  gleeunit.main()
}

pub fn find_test() {
  let conn = db.open("database.sqlite3")
  let result = repo.find(conn, domain.ticket_id("1"))

  result
  |> should.be_ok
}
