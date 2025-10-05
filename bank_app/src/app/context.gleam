import features/account/adaptor/event_store/on_sqlite
import features/account/application/port
import features/account/application/usecase
import shared/db
import shared/ffi/os
import shared/uuid

pub type Usecase {
  Usecase(deposit: port.Deposit, create: port.Create)
}

pub type Context {
  Context(
    connection: db.Connection,
    generate_id: uuid.Generate,
    usecase: Usecase,
  )
}

pub fn new() -> Context {
  let assert Ok(basepath) = os.get_cwd()
  let connection = db.new(basepath <> "/db/database.sqlite3")
  let deps = deps(connection)

  let account_usecase =
    Usecase(
      deposit: fn() {
        // usecase.deposit(deps.generate_id, deps.load_events, deps.append_events)
        todo
      },
      create: fn() { todo },
    )

  Context(connection:, generate_id: deps.generate_id, usecase: account_usecase)
}

pub type Deps {
  Deps(
    generate_id: uuid.Generate,
    load_events: port.LoadEvents,
    append_events: port.AppendEvents,
  )
}

fn deps(connection: db.Connection) -> Deps {
  Deps(
    generate_id: uuid.v4,
    load_events: on_sqlite.load_events(connection),
    append_events: on_sqlite.append_events(connection),
  )
}
