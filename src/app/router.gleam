import app/context
import app/router/api_router
import app/router/web_router
import lib/http_core.{type Request, type Response}

pub fn handle_request(ctx: context.Context, req: Request) -> Response {
  case http_core.path_segments(req), req.method {
    ["api", ..], _ -> api_router.handle_request(ctx, req)
    _, _ -> web_router.handle_request(ctx, req)
  }
}

fn auth_middleware(req: Request) -> Result(String, Nil) {
  let cookie = http_core.get_cookie_with_signed(req, "auth")
  todo
}
