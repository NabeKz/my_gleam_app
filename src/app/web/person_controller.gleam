import app/web/person.{
  type Person, type PersonReadModel, type PersonRepository, Person,
}
import gleam/dynamic/decode
import gleam/http
import gleam/json
import gleam/result
import wisp.{type Request, type Response}

pub fn routes(req: Request, ctx: PersonRepository) -> Response {
  case req.method {
    http.Get -> list_person(ctx)
    http.Post -> create_person(ctx, req)
    _ -> wisp.method_not_allowed([http.Get, http.Post])
  }
}

fn list_person(repository: PersonRepository) -> Response {
  let result = {
    use persons <- result.try(repository.all())

    let callback = fn(person: PersonReadModel) -> json.Json {
      json.object([
        #("id", json.string(person.id)),
        #("name", json.string(person.name)),
        #("favorite_color", json.string(person.favorite_color)),
      ])
    }

    persons
    |> json.array(callback)
    |> json.to_string_tree()
    |> Ok()
  }

  case result {
    Ok(json) -> wisp.json_response(json, 200)
    Error(_) -> wisp.internal_server_error()
  }
}

fn create_person(repository: PersonRepository, req: Request) -> Response {
  use json <- wisp.require_json(req)

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
    Ok(json) -> wisp.json_response(json, 201)
    Error(_) -> wisp.unprocessable_entity()
  }
}

fn read_person(ctx: PersonRepository, id: String) -> Response {
  let result = {
    use person <- result.try(ctx.read(id))

    [
      #("id", json.string(id)),
      #("name", json.string(person.name)),
      #("favorite_color", json.string(person.favorite_color)),
    ]
    |> json.object()
    |> json.to_string_tree()
    |> Ok()
  }

  case result {
    Ok(json) -> wisp.json_response(json, 200)
    Error(_) -> wisp.internal_server_error()
  }
}

fn delete_person() -> Response {
  todo
}

fn decode_person() -> decode.Decoder(Person) {
  use name <- decode.field("name", decode.string)
  use favorite_color <- decode.field("favorite-color", decode.string)
  decode.success(Person(name:, favorite_color:))
}
