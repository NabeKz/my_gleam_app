import app/ticket/usecase/ticket_created
import app/ticket/usecase/ticket_listed
import gleam/dynamic/decode
import gleam/http
import gleam/json
import gleam/result
import wisp

pub type Resolver {
  Resolver(ticket_listed: ticket_listed.Output)
}

pub fn routes(
  path: List(String),
  req: wisp.Request,
  resolver: Resolver,
) -> wisp.Response {
  case path, req.method {
    [], http.Get -> get(req, resolver.ticket_listed)
    [], http.Post -> post(req)
    _, _ -> wisp.not_found()
  }
}

///
fn get(_req: wisp.Request, usecase: ticket_listed.Output) -> wisp.Response {
  usecase()
  |> json.to_string_tree()
  |> wisp.json_response(200)
}

///
///
fn post(req: wisp.Request) -> wisp.Response {
  use json <- wisp.require_json(req)

  let result = {
    use _dto <- result.try(decode.run(json, decode_ticket()))

    json.string("ok")
    |> json.to_string_tree()
    |> Ok()
  }

  case result {
    Ok(json) -> wisp.json_response(json, 201)
    Error(_) -> wisp.bad_request()
  }
}

fn decode_ticket() -> decode.Decoder(ticket_created.Dto) {
  use title <- decode.field("title", decode.string)
  use description <- decode.field("description", decode.string)
  use status <- decode.field("status", decode.string)
  decode.success(ticket_created.Dto(title:, description:, status:))
}
