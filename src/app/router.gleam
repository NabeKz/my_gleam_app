import app/context
import app/router/api_router
import app/router/web_router
import lib/http_core.{type Request, type Response}

pub fn handle_request(ctx: context.Context, req: Request) -> Response {
  use req <- auth_middleware(req)

  case http_core.path_segments(req), req.method {
    ["api", ..], _ -> api_router.handle_request(ctx, req)
    _, _ -> web_router.handle_request(ctx, req)
  }
}

fn auth_middleware(
  req: Request,
  handle_request: fn(Request) -> Response,
) -> Response {
  let cookie = http_core.get_cookie_with_signed(req, "authorization")
  let authorized = case cookie {
    Ok(cookie) -> auth_provider(cookie)
    _ -> False
  }
  case authorized {
    True -> handle_request(req)
    False -> handle_request(req)
  }
}

fn auth_provider(token: String) -> Bool {
  echo token
  True
}
