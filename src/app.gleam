import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

import app/context
import app/router

// import lib/db

pub fn main() {
  wisp.configure_logger()
  // let db = db.open("database.sqlite3")
  // Here we generate a secret key, but in a real application you would want to
  // load this from somewhere so that it is not regenerated on every restart.
  let secret_key = wisp.random_string(64)
  let context = context.on_ets()

  let controller = router.handle_request(context, _)

  let assert Ok(_) =
    wisp_mist.handler(controller, secret_key)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
