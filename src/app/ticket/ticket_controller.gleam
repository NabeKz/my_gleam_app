import gleam/http
import gleam/json
import gleam/result
import wisp

import app/ticket/usecase/ticket_created
import app/ticket/usecase/ticket_deleted
import app/ticket/usecase/ticket_listed
import app/ticket/usecase/ticket_searched
import lib/deserializer

pub type Resolver {
  Resolver(
    listed: ticket_listed.Workflow,
    created: ticket_created.Output,
    searched: ticket_searched.Output,
    deleted: ticket_deleted.Output,
  )
}

pub fn routes(
  path: List(String),
  req: wisp.Request,
  resolver: Resolver,
) -> wisp.Response {
  case path, req.method {
    [], http.Get -> list(req, resolver.listed)
    [], http.Post -> post(req, resolver.created)
    [id], http.Get -> get_one(id, resolver.searched)
    [id], http.Delete -> delete(id, resolver.deleted)
    _, _ -> wisp.not_found()
  }
}

///
fn list(req: wisp.Request, usecase: ticket_listed.Workflow) -> wisp.Response {
  let params = req |> wisp.get_query()

  case usecase(params) {
    Ok(tickets) ->
      tickets
      |> json.to_string_tree()
      |> wisp.json_response(200)
    Error(error) -> {
      error
      |> deserializer.deserialize_error
      |> json.to_string_tree()
      |> wisp.json_response(400)
    }
  }
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

///
///
fn get_one(id: String, usecase: ticket_searched.Output) -> wisp.Response {
  let result = {
    use dto <- result.try(usecase(id))

    dto
    |> json.to_string_tree
    |> Ok()
  }

  case result {
    Ok(json) -> wisp.json_response(json, 200)
    Error(_) -> wisp.bad_request()
  }
}

///
///
fn delete(id: String, usecase: ticket_deleted.Output) -> wisp.Response {
  let result = {
    use dto <- result.try(usecase(id))

    dto
    |> json.to_string_tree
    |> Ok()
  }

  case result {
    Ok(json) -> wisp.json_response(json, 200)
    Error(_) -> wisp.bad_request()
  }
}
