import gleam/int
import gleam/list
import gleam/string

pub type Date {
  Date(year: Int, month: Int, day: Int)
}

pub type Time {
  Time(hour: Int, minute: Int, second: Int)
}

/// @see
/// https://www.erlang.org/doc/apps/stdlib/calendar.html
@external(erlang, "calendar", "local_time")
fn local_time() -> #(#(Int, Int, Int), #(Int, Int, Int))

// 日付に日数を加算
@external(erlang, "calendar", "date_to_gregorian_days")
fn date_to_gregorian_days(date: #(Int, Int, Int)) -> Int

@external(erlang, "calendar", "gregorian_days_to_date")
fn gregorian_days_to_date(days: Int) -> #(Int, Int, Int)

pub fn now() -> Date {
  let #(date, _) = local_time()
  let #(year, month, day) = date

  Date(year:, month:, day:)
}

pub fn from(date: #(Int, Int, Int)) -> Date {
  Date(date.0, date.1, date.2)
}

pub fn add_days(date: Date, days: Int) -> Date {
  #(date.year, date.month, date.day)
  |> date_to_gregorian_days()
  |> int.add(days)
  |> gregorian_days_to_date()
  |> from()
}

pub fn from_string(value: String) -> Result(Date, String) {
  let date = {
    let value = value |> string.split("-")
    use value <- list.try_map(value)
    value |> int.parse()
  }

  case date {
    Ok([year, month, day]) -> Ok(Date(year:, month:, day:))
    _ -> Error("invalid date")
  }
}

pub fn to_string(date: Date) -> String {
  [int.to_string(date.year), int.to_string(date.month), int.to_string(date.day)]
  |> list.map(fn(it) { it |> string.pad_start(2, "0") })
  |> string.join("-")
}
