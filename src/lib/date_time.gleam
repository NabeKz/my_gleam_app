import gleam/int
import gleam/list
import gleam/string

pub type Date {
  Date(year: Int, month: Int, day: Int)
}

pub type Time {
  Time(hour: Int, minute: Int, second: Int)
}

/// see
/// https://www.erlang.org/doc/apps/stdlib/calendar.html
@external(erlang, "calendar", "local_time")
fn local_time() -> #(#(Int, Int, Int), #(Int, Int, Int))

pub fn now() -> Date {
  let #(date, _) = local_time()
  let #(year, month, day) = date

  Date(year:, month:, day:)
}

pub fn from_string(value: String) -> Result(Date, String) {
  let date =
    value
    |> string.split("-")
    |> list.try_map(fn(val) { int.parse(val) })

  case date {
    Ok([year, month, day]) -> Ok(Date(year:, month:, day:))
    _ -> Error("invalid date")
  }
}

pub fn to_string(date: Date) -> String {
  [int.to_string(date.year), int.to_string(date.month), int.to_string(date.day)]
  |> string.join("-")
}
