import gleeunit/should

import features/account/usecase
import shared/db
import sqlight

fn new_connection() -> db.Connection {
  db.new(":memory:")
}

fn create_journals_table(connection: db.Connection) -> Nil {
  let assert Ok(_) =
    db.exec_with(
      db.sql(
        "\n        CREATE TABLE journals (\n          id INTEGER PRIMARY KEY AUTOINCREMENT,\n          aggregate_type TEXT NOT NULL,\n          aggregate_id TEXT NOT NULL,\n          version INTEGER NOT NULL,\n          event_type TEXT NOT NULL,\n          event TEXT NOT NULL,\n          created_at TEXT NOT NULL DEFAULT (datetime('now')),\n          UNIQUE(aggregate_type, aggregate_id, version)\n        );\n        ",
        [],
      ),
      connection,
    )

  let assert Ok(_) =
    db.exec_with(
      db.sql(
        "\n        CREATE INDEX journals_aggregate_idx\n          ON journals (aggregate_type, aggregate_id);\n        ",
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
        "\n        INSERT INTO journals (\n          aggregate_type,\n          aggregate_id,\n          version,\n          event_type,\n          event,\n          created_at\n        ) VALUES (?, ?, ?, ?, ?, ?);\n        ",
        [
          sqlight.text("account"),
          sqlight.text("counter-123"),
          sqlight.int(1),
          sqlight.text("account.deposited"),
          sqlight.text("{\"amount\":100}"),
          sqlight.text("2024-01-01T00:00:00Z"),
        ],
      ),
      connection,
    )

  case usecase.invoke(connection) {
    Ok(journals) -> {
      assert journals
        == [
          usecase.Journal(
            1,
            "account",
            "counter-123",
            1,
            "account.deposited",
            "{\"amount\":100}",
            "2024-01-01T00:00:00Z",
          ),
        ]

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
          assert journals
            == [
              usecase.Journal(
                1,
                "account",
                "counter-1",
                1,
                "account.deposited",
                "credited",
                "2025-10-10T00:00:00Z",
              ),
            ]

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
