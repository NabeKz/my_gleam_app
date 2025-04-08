import gleam/json
import gleam/result
import wisp.{type Response}

pub type Person {
  Person(name: String, favorite_color: String)
}

type Context =
  fn() -> Result(List(String), List(String))

fn list_people(ctx: Context) -> Response {
  let result = {
    use ids <- result.try(ctx())
    let callback = fn(id: String) -> json.Json {
      json.object([#("id", json.string(id))])
    }
    let items = ids |> json.array(callback)

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
