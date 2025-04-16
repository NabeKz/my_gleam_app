import app/ticket/usecase/ticket_created
import app/ticket/usecase/ticket_listed
import gleam/http
import gleam/json
import gleam/result
import wisp

pub type Resolver {
  Resolver(
    ticket_listed: ticket_listed.Output,
    ticket_created: ticket_created.Output,
  )
}

pub fn routes(
  path: List(String),
  req: wisp.Request,
  resolver: Resolver,
) -> wisp.Response {
  case path, req.method {
    [], http.Get -> get(req, resolver.ticket_listed)
    [], http.Post -> post(req, resolver.ticket_created)
    _, _ -> wisp.not_found()
  }
}

///
fn get(_req: wisp.Request, usecase: ticket_listed.Output) -> wisp.Response {
  usecase(Nil)
  |> json.to_string_tree()
  |> wisp.json_response(200)
}

///
///
fn post(req: wisp.Request, usecase: ticket_created.Output) -> wisp.Response {
  use json <- wisp.require_json(req)

  let result = {
    use _dto <- result.try(usecase(json))

    json.string("ok")
    |> json.to_string_tree()
    |> Ok()
  }

  case result {
    Ok(json) -> wisp.json_response(json, 201)
    Error(_) -> wisp.bad_request()
  }
}
