import gleam/http.{Get}
import gleam/json
import gleam/result
import wisp

import app/context
import shared/db/db

pub fn handle_request(ctx: context.Context, req: wisp.Request) -> wisp.Response {
  let path = wisp.path_segments(req)

  case path, req.method {
    ["health"], Get -> {
      json.string("ok")
      |> json.to_string()
      |> wisp.json_response(200)
    }
    ["db"], Get -> {
      db.exec(ctx.connection)
      |> result.map(fn(_) { wisp.created() })
      |> result.map_error(fn(_) { wisp.bad_request("ng") })
      |> result.unwrap_both()
    }
    _, _ -> wisp.not_found()
  }
}
