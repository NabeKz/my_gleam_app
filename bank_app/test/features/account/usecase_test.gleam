import gleeunit/should

import features/account/usecase
import shared/db
import sqlight

fn new_connection() -> db.Connection {
  let assert Ok(sql_connection) = sqlight.open(":memory:")

  db.Connection(sql_connection)
}

fn create_journals_table(connection: db.Connection) -> Nil {
  let assert Ok(_) =
    db.exec_with(
      db.sql(
        "CREATE TABLE journals (id INTEGER PRIMARY KEY AUTOINCREMENT, aggregate_type TEXT NOT NULL, event TEXT NOT NULL, created_at TEXT NOT NULL);",
        [],
      ),
      connection,
    )

  Nil
}

pub fn invoke_returns_journals_test() {
  let connection = new_connection()
  create_journals_table(connection)

  let assert Ok(_) =
    db.exec_with(
      db.sql(
        "INSERT INTO journals (aggregate_type, event, created_at) VALUES (?, ?, ?);",
        [
          sqlight.text("account"),
          sqlight.text("Upped"),
          sqlight.text("2024-01-01T00:00:00Z"),
        ],
      ),
      connection,
    )

  case usecase.invoke(connection) {
    Ok(journals) -> {
      assert journals
        == [usecase.Journal(1, "account", "Upped", "2024-01-01T00:00:00Z")]

      Nil
    }
    Error(_) -> should.fail()
  }
}

pub fn invoke_returns_error_when_query_fails_test() {
  let connection = new_connection()

  case usecase.invoke(connection) {
    Error(message) -> {
      assert message == "ng"

      Nil
    }
    Ok(_) -> should.fail()
  }
}

pub fn exec_inserts_journal_entry_test() {
  let connection = new_connection()
  create_journals_table(connection)

  case usecase.exec(connection) {
    Ok(result) -> {
      assert result == "ok"

      case usecase.invoke(connection) {
        Ok(journals) -> {
          assert journals == [usecase.Journal(1, "a", "c", "2025-10-10")]

          Nil
        }
        Error(_) -> should.fail()
      }
    }
    Error(_) -> should.fail()
  }
}

pub fn exec_returns_error_when_insert_fails_test() {
  let connection = new_connection()

  case usecase.exec(connection) {
    Error(message) -> {
      assert message == "ng"

      Nil
    }
    Ok(_) -> should.fail()
  }
}
