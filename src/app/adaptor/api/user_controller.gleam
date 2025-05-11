import gleam/dynamic/decode
import gleam/http
import gleam/json
import gleam/result

import app/features/user/user.{type UserRepository}
import lib/http_core.{type Request, type Response}

pub fn routes(req: Request, ctx: UserRepository) -> Response {
  case req.method {
    http.Get -> list_user(ctx)
    http.Post -> create_user(ctx, req)
    _ -> http_core.method_not_allowed([http.Get, http.Post])
  }
}

fn list_user(repository: UserRepository) -> Response {
  let result = {
    use users <- result.try(repository.listed())

    let users = {
      use user <- json.array(users)

      json.object([
        #("id", json.string(user.id)),
        #("name", json.string(user.name)),
        #("favorite_color", json.string(user.favorite_color)),
      ])
    }

    users
    |> json.to_string_tree()
    |> Ok()
  }

  case result {
    Ok(json) -> http_core.json_response(json, 200)
    Error(_) -> http_core.internal_server_error()
  }
}

fn create_user(repository: UserRepository, req: Request) -> Response {
  use json <- http_core.require_json(req)

  let result = {
    use person <- result.try(decode.run(json, decode_user()))
    let id = case repository.save(person) {
      Ok(value) -> value
      Error(_) -> ""
    }

    [#("id", json.string(id))]
    |> json.object()
    |> json.to_string_tree()
    |> Ok()
  }

  case result {
    Ok(json) -> http_core.json_response(json, 201)
    Error(_) -> http_core.unprocessable_entity()
  }
}

fn decode_user() -> decode.Decoder(user.User) {
  use name <- decode.field("name", decode.string)
  use favorite_color <- decode.field("favorite-color", decode.string)

  decode.success(user.Member(name:, favorite_color:))
}
