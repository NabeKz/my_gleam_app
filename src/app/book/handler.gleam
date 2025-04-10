import wisp

pub fn handle_request(req: wisp.Request) -> wisp.Response {
  case wisp.path_segments(req) {
    _ -> wisp.not_found()
  }
}
