import gleam/list
import gleam/string
import sqlight

pub type Conn =
  sqlight.Connection

pub const exec = sqlight.exec

pub fn escape(values: List(String)) -> String {
  list.map(values, fn(it) { "'" <> it <> "'" })
  |> string.join(",")
}
