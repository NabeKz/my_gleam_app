import gleam/dynamic/decode
import gleam/http
import gleam/json
import gleam/option
import gleam/result

import app/features/user/user.{type PersonRepository}
import lib/http_core.{type Request, type Response}

pub fn routes(req: Request, ctx: PersonRepository) -> Response {
  case req.method {
    http.Get -> list_person(ctx)
    http.Post -> create_person(ctx, req)
    _ -> http_core.method_not_allowed([http.Get, http.Post])
  }
}

fn list_person(repository: PersonRepository) -> Response {
  let result = {
    use users <- result.try(repository.all())

    let users = {
      use user <- json.array(users)

      let favorite_color = case user.favorite_color {
        option.Some(value) -> value
        option.None -> ""
      }

      json.object([
        #("id", json.string(user.id)),
        #("name", json.string(user.name)),
        #("favorite_color", json.string(favorite_color)),
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

fn create_person(repository: PersonRepository, req: Request) -> Response {
  use json <- http_core.require_json(req)

  let result = {
    use person <- result.try(decode.run(json, decode_person()))
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

fn decode_person() -> decode.Decoder(user.Person) {
  use name <- decode.field("name", decode.string)
  use favorite_color <- decode.field("favorite-color", decode.string)

  decode.success(user.Member(name:, favorite_color:))
}
