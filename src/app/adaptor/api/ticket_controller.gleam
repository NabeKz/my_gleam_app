import gleam/http
import gleam/json
import gleam/result

import app/features/ticket/usecase/ticket_created
import app/features/ticket/usecase/ticket_deleted
import app/features/ticket/usecase/ticket_listed
import app/features/ticket/usecase/ticket_searched
import app/features/ticket/usecase/ticket_updated
import lib/deserializer
import lib/http_core.{type Request, type Response}

pub type Resolver {
  Resolver(
    listed: ticket_listed.Workflow,
    created: ticket_created.Workflow,
    searched: ticket_searched.Workflow,
    updated: ticket_updated.Workflow,
    deleted: ticket_deleted.Workflow,
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
      |> ticket_listed.deserialize()
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
fn post(req: Request, usecase: ticket_created.Workflow) -> Response {
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
fn get_one(id: String, usecase: ticket_searched.Workflow) -> http_core.Response {
  let result = {
    use dto <- result.try(usecase(id))

    dto
    |> ticket_searched.deserialize()
    |> json.to_string_tree()
    |> Ok()
  }

  case result {
    Ok(json) -> http_core.json_response(json, 200)
    Error(_) -> http_core.bad_request()
  }
}

///
///
fn delete(id: String, usecase: ticket_deleted.Workflow) -> http_core.Response {
  let result = {
    use _ <- result.try(usecase(id))

    json.null()
    |> json.to_string_tree()
    |> Ok()
  }

  case result {
    Ok(json) -> http_core.json_response(json, 200)
    Error(_) -> http_core.bad_request()
  }
}
