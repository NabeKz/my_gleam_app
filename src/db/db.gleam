import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import gleam/string
import sqlight

pub type Conn =
  sqlight.Connection

pub type SqlError =
  sqlight.Error

pub const exec = sqlight.exec

pub const query = sqlight.query

pub fn placeholder(value: a) -> sqlight.Value {
  let assert Ok(value) = dynamic.from(value) |> decode.run(decode.string)
  // let value = result.map(value |>)
  sqlight.text(value)
}

pub fn escape(values: List(String)) -> String {
  list.map(values, fn(it) { "'" <> it <> "'" })
  |> string.join(",")
}
