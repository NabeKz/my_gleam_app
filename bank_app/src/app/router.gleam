import features/account/adaptor/api/account_api
import gleam/http.{Get, Post}
import wisp

import app/context

pub fn handle_request(ctx: context.Context, req: wisp.Request) -> wisp.Response {
  let path = wisp.path_segments(req)

  case path, req.method {
    ["counter"], Get -> wisp.not_found()

    ["counter"], Post -> account_api.post(ctx.usecase.create)
    _, _ -> wisp.not_found()
  }
}
