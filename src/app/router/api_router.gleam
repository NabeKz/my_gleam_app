import app/adaptor/api/ticket_controller
import app/context
import app/features/user/user_controller
import lib/http_core.{type Request, type Response}

pub fn handle_request(ctx: context.Context, req: Request) -> Response {
  use req <- middleware(req)
  use path <- parse_path(req)

  case path, req.method {
    ["users"], _ -> user_controller.routes(req, ctx.user)
    ["tickets", ..path], _ -> ticket_controller.routes(path, req, ctx.ticket)
    _, _ -> http_core.not_found()
  }
}

fn middleware(req: Request, resp: fn(Request) -> Response) -> Response {
  resp(req)
}

fn parse_path(req: Request, resp: fn(List(String)) -> Response) -> Response {
  case http_core.path_segments(req) {
    ["api", ..rest] -> rest
    _ -> []
  }
  |> resp()
}
