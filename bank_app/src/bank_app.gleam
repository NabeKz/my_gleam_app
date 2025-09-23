import app/context
import app/router
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

import shared/db/db

pub fn main() -> Nil {
  wisp.configure_logger()
  // let db = db.open("database.sqlite3")
  // Here we generate a secret key, but in a real application you would want to
  // load this from somewhere so that it is not regenerated on every restart.
  let secret_key = wisp.random_string(64)
  // let context = context.on_ets()
  let context = context.Context(connection: db.new())

  let controller = router.handle_request(context, _)

  let assert Ok(_) =
    wisp_mist.handler(controller, secret_key)
    |> mist.new
    |> mist.port(8000)
    |> mist.start

  process.sleep_forever()
}
