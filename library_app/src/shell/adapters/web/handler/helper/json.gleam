import core/shared/types/user
import gleam/dynamic
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option
import gleam/string
import wisp

pub type Json =
  json.Json

fn parse_decode_error(error: decode.DecodeError) -> json.Json {
  [#("message", error.expected), #("path", error.path |> string.join(","))]
  |> list.map(fn(it) { #(it.0, it.1 |> json.string) })
  |> json.object()
}

fn parse_error(error: json.DecodeError) -> List(decode.DecodeError) {
  case error {
    json.UnableToDecode(errors) -> errors
    json.UnexpectedByte(error) | json.UnexpectedSequence(error) -> {
      echo error
      decode.decode_error("invalid json format", dynamic.string("json format"))
    }
    _ -> decode.decode_error("unexpected_error", dynamic.string("json format"))
  }
}

pub fn authenticated(
  req: wisp.Request,
  auth: fn(List(#(String, String))) -> Result(user.User, String),
  next: fn(user.User) -> wisp.Response,
) -> wisp.Response {
  case auth(req.headers) {
    Ok(user) -> next(user)
    Error(err) -> {
      wisp.response(401)
      |> wisp.string_body(err)
    }
  }
}

pub fn ok(body: json.Json) -> wisp.Response {
  body
  |> json.to_string_tree()
  |> wisp.json_response(200)
}

pub fn bad_request(body: json.Json) -> wisp.Response {
  body
  |> json.to_string_tree()
  |> wisp.json_response(400)
}

pub fn error(errors: List(String)) -> json.Json {
  errors
  |> json.array(json.string)
}

pub const string = json.string

pub const int = json.int

pub const object = json.object

pub const array = json.array

pub fn map_or(
  value: option.Option(a),
  then: fn(a) -> b,
  second: b,
  serialize: fn(b) -> json.Json,
) -> json.Json {
  value
  |> option.map(then)
  |> option.or(second |> option.Some)
  |> json.nullable(serialize)
}

// TODO: error handling
pub fn get_body(
  req: wisp.Request,
  decoder: fn() -> decode.Decoder(t),
  next: fn(t) -> wisp.Response,
) -> wisp.Response {
  use <- wisp.require_content_type(req, "application/json")
  use body <- wisp.require_string_body(req)
  let json = json.parse(body, decoder())

  case json {
    Ok(value) -> next(value)
    Error(error) -> {
      error
      |> parse_error()
      |> json.array(parse_decode_error)
      |> json.to_string_tree()
      |> wisp.json_response(400)
    }
  }
}

// TODO: error handling
pub fn get_query(
  req: wisp.Request,
  decoder: fn() -> decode.Decoder(t),
  next: fn(t) -> wisp.Response,
) {
  let query = wisp.get_query(req)
  let query = {
    use it <- list.map(query)
    #(it.0 |> dynamic.string, it.1 |> dynamic.string)
  }
  let query = decode.run(query |> dynamic.properties, decoder())
  case query {
    Ok(query) -> next(query)
    Error(_) -> wisp.bad_request()
  }
}
