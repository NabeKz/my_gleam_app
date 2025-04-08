import app/web/person
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

import app/router

pub fn main() {
  wisp.configure_logger()
  // Here we generate a secret key, but in a real application you would want to
  // load this from somewhere so that it is not regenerated on every restart.
  let secret_key = wisp.random_string(64)
  let ctx =
    person.Context(
      list: fn() { todo },
      save: fn(p: person.Person) { todo },
      read: fn(s: String) { todo },
      delete: fn() { todo },
    )

  let controller = router.handle_request(ctx, _)

  let assert Ok(_) =
    wisp_mist.handler(controller, secret_key)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
