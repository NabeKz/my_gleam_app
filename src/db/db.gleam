import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import gleam/string
import sqlight

pub type Conn =
  sqlight.Connection

pub type Error =
  sqlight.Error

pub type ErrorMessage {
  NotFound
  MultiRecordFound
  SqlError(message: String)
}

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

pub fn handle_find_result(
  result: Result(List(a), Error),
) -> Result(a, ErrorMessage) {
  case result {
    Ok([first]) -> Ok(first)
    Ok([]) -> Error(NotFound)
    Ok([_, ..]) -> Error(MultiRecordFound)
    Error(err) -> Error(SqlError(err.message))
  }
}
