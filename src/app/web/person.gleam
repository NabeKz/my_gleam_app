import gleam/dynamic/decode
import gleam/http
import gleam/json
import gleam/result
import wisp.{type Request, type Response}

pub type Person {
  Person(name: String, favorite_color: String)
}

pub type Context {
  Context(
    list: fn() -> Result(List(String), List(String)),
    save: fn(Person) -> Result(String, List(String)),
    read: fn(String) -> Result(Person, List(String)),
    delete: fn() -> Result(List(String), List(String)),
  )
}

pub fn person_controller(req: Request, ctx: Context) -> Response {
  case req.method {
    http.Get -> list_person(ctx)
    http.Post -> create_person(req, ctx)
    _ -> wisp.method_not_allowed([http.Get, http.Post])
  }
}

fn list_person(ctx: Context) -> Response {
  let result = {
    use ids <- result.try(ctx.list())

    let callback = fn(id: String) -> json.Json {
      json.object([#("id", json.string(id))])
    }
    let items =
      ids
      |> json.array(callback)

    [#("people", items)]
    |> json.object()
    |> json.to_string_tree()
    |> Ok()
  }

  case result {
    Ok(json) -> wisp.json_response(json, 200)
    Error(_) -> wisp.internal_server_error()
  }
}

fn create_person(req: Request, ctx: Context) -> Response {
  use json <- wisp.require_json(req)

  let result = {
    use person <- result.try(decode.run(json, decode_person()))
    let id = case ctx.save(person) {
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

fn read_person(ctx: Context, id: String) -> Response {
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
