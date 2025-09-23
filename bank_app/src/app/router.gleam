import features/account/usecase
import gleam/http.{Get, Post}
import gleam/json
import gleam/result
import wisp

import app/context

pub fn handle_request(ctx: context.Context, req: wisp.Request) -> wisp.Response {
  let path = wisp.path_segments(req)

  case path, req.method {
    ["health"], Get -> {
      json.string("ok")
      |> json.to_string()
      |> wisp.json_response(200)
    }
    ["db"], Get -> {
      usecase.invoke(ctx.connection)
      |> result.map(fn(_) { wisp.ok() })
      |> result.map_error(fn(_) { wisp.bad_request("ng") })
      |> result.unwrap_both()
    }
    ["db"], Post -> {
      usecase.exec(ctx.connection)
      |> result.map(fn(_) { wisp.created() })
      |> result.map_error(fn(_) { wisp.bad_request("ng") })
      |> result.unwrap_both()
    }
    _, _ -> wisp.not_found()
  }
}
