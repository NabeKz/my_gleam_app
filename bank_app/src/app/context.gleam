import features/account/adaptor/rdb
import features/account/usecase/deposit
import features/account/usecase/port
import shared/db
import shared/ffi/os
import shared/uuid

pub type Usecase {
  Usecase(account: port.Usecase)
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
    port.Usecase(deposit: fn() {
      deposit.deposit(deps.generate_id, deps.load_events, deps.append_events)
    })

  Context(
    connection:,
    generate_id: deps.generate_id,
    usecase: Usecase(account: account_usecase),
  )
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
    load_events: rdb.load_events(connection),
    append_events: rdb.append_events(connection),
  )
}
