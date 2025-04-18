import gleam/int
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

pub fn to_string(date: Date) -> String {
  [int.to_string(date.year), int.to_string(date.month), int.to_string(date.day)]
  |> string.join("-")
}
