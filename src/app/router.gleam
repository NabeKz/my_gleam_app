import app/web
import gleam/dynamic/decode
import gleam/http.{Get, Post}
import gleam/json
import gleam/result
import gleam/string_tree
import wisp.{type Request, type Response}

type Person {
  Person(name: String, is_cool: Bool)
}

pub fn handle_request(req: Request) -> Response {
  use _res <- web.middleware(req)

  case wisp.path_segments(req), req.method {
    [], Get -> home_page(req)
    ["comments"], Get -> list_comments()
    ["comments"], Post -> create_comment(req)
    ["comments", id], Get -> show_comment(req, id)
    ["persons"], Post -> create_person(req)
    _, _ -> wisp.not_found()
  }
}

fn person_decoder() -> decode.Decoder(Person) {
  use name <- decode.field("name", decode.string)
  use is_cool <- decode.field("is-cool", decode.bool)
  decode.success(Person(name:, is_cool:))
}

fn create_person(req: Request) -> Response {
  use json <- wisp.require_json(req)

  let result = {
    use person <- result.try(decode.run(json, person_decoder()))
    let object =
      json.object([
        #("name", json.string(person.name)),
        #("is_cool", json.bool(person.is_cool)),
        #("saved", json.bool(True)),
      ])
    Ok(json.to_string_tree(object))
  }

  case result {
    Ok(json) -> wisp.json_response(json, 201)
    Error(_) -> wisp.unprocessable_entity()
  }
}

fn home_page(req: Request) -> Response {
  use <- wisp.require_method(req, Get)
  let html = string_tree.from_string("Hello, Joe!")

  wisp.ok()
  |> wisp.html_body(html)
}

fn list_comments() -> Response {
  let html = string_tree.from_string("Comments!")

  wisp.ok()
  |> wisp.html_body(html)
}

fn create_comment(_req: Request) -> Response {
  let html = string_tree.from_string("Created")

  wisp.ok()
  |> wisp.html_body(html)
}

fn show_comment(req: Request, id: String) -> Response {
  use <- wisp.require_method(req, Get)
  let html = string_tree.from_string("Comment with id " <> id)

  wisp.ok()
  |> wisp.html_body(html)
}
