import mist
import wisp
import wisp/wisp_mist

import app/context
import gleam/erlang/process
import shell/adapters/web/router

pub fn run() {
  wisp.configure_logger()
  // Here we generate a secret key, but in a real application you would want to
  // load this from somewhere so that it is not regenerated on every restart.
  let secret_key = wisp.random_string(64)
  let ctx = context.new()
  let controller = router.handle_request(_, ctx)

  let assert Ok(_) =
    wisp_mist.handler(controller, secret_key)
    |> mist.new
    |> mist.port(8000)
    |> mist.start

  process.sleep_forever()
}
