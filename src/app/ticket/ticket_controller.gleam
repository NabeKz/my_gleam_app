import gleam/http
import gleam/json
import gleam/result

import app/ticket/usecase/ticket_created
import app/ticket/usecase/ticket_deleted
import app/ticket/usecase/ticket_listed
import app/ticket/usecase/ticket_searched
import lib/deserializer
import lib/http_core.{type Request, type Response}

pub type Resolver {
  Resolver(
    listed: ticket_listed.Workflow,
    created: ticket_created.Output,
    searched: ticket_searched.Output,
    deleted: ticket_deleted.Output,
  )
}

pub fn routes(path: List(String), req: Request, resolver: Resolver) -> Response {
  case path, req.method {
    [], http.Get -> list(req, resolver.listed)
    [], http.Post -> post(req, resolver.created)
    [id], http.Get -> get_one(id, resolver.searched)
    [id], http.Delete -> delete(id, resolver.deleted)
    _, _ -> http_core.not_found()
  }
}

///
fn list(req: Request, usecase: ticket_listed.Workflow) -> http_core.Response {
  let params = req |> http_core.get_query()

  case usecase(params) {
    Ok(tickets) ->
      tickets
      |> json.to_string_tree()
      |> http_core.json_response(200)
    Error(error) -> {
      error
      |> deserializer.deserialize_error
      |> json.to_string_tree()
      |> http_core.json_response(400)
    }
  }
}

///
///
fn post(req: Request, usecase: ticket_created.Output) -> Response {
  use json <- http_core.require_json(req)

  let result = {
    use _dto <- result.try(usecase(json))

    json.string("ok")
    |> json.to_string_tree()
    |> Ok()
  }

  case result {
    Ok(json) -> http_core.json_response(json, 201)
    Error(_) -> http_core.bad_request()
  }
}

///
///
fn get_one(id: String, usecase: ticket_searched.Output) -> http_core.Response {
  let result = {
    use dto <- result.try(usecase(id))

    dto
    |> json.to_string_tree
    |> Ok()
  }

  case result {
    Ok(json) -> http_core.json_response(json, 200)
    Error(_) -> http_core.bad_request()
  }
}

///
///
fn delete(id: String, usecase: ticket_deleted.Output) -> http_core.Response {
  let result = {
    use dto <- result.try(usecase(id))

    dto
    |> json.to_string_tree
    |> Ok()
  }

  case result {
    Ok(json) -> http_core.json_response(json, 200)
    Error(_) -> http_core.bad_request()
  }
}
