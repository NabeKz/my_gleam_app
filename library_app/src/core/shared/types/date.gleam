import gleam/int
import gleam/list
import gleam/order
import gleam/string

pub type Timestamp {
  Timestamp(value: Int)
}

pub type LocalTime =
  #(#(Int, Int, Int), #(Int, Int, Int))

pub type DateTime {
  DateTime(date: Date, time: Time)
}

pub type Date {
  Date(year: Int, month: Int, day: Int)
}

pub type Time {
  Time(hour: Int, minute: Int, second: Int)
}

pub type GetDate =
  fn() -> Date

/// @see
/// https://www.erlang.org/doc/apps/stdlib/calendar.html
@external(erlang, "calendar", "local_time")
fn local_time() -> LocalTime

// 日付に日数を加算
@external(erlang, "calendar", "date_to_gregorian_days")
fn date_to_gregorian_days(date: #(Int, Int, Int)) -> Int

@external(erlang, "calendar", "gregorian_days_to_date")
fn gregorian_days_to_date(days: Int) -> #(Int, Int, Int)

@external(erlang, "calendar", "datetime_to_gregorian_seconds")
fn datetime_to_gregorian_seconds(local_time: LocalTime) -> Int

@external(erlang, "os", "timestamp")
pub fn timestamp_ffi() -> #(Int, Int, Int)

pub fn timestamp() -> Timestamp {
  let #(mega_secs, secs, micro_secs) = timestamp_ffi()
  let value = mega_secs * 1_000_000_000_000 + secs * 1_000_000 + micro_secs
  Timestamp(value:)
}

pub fn inner(timestamp: Timestamp) -> Int {
  timestamp.value
}

pub fn now() -> DateTime {
  let #(date, time) = local_time()

  DateTime(Date(date.0, date.1, date.2), Time(time.0, time.1, time.2))
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

pub fn compare(a: Date, order: order.Order, b: Date) -> Bool {
  let a =
    datetime_to_gregorian_seconds(#(#(a.year, a.month, a.day), #(0, 0, 0)))
  let b =
    datetime_to_gregorian_seconds(#(#(b.year, b.month, b.day), #(0, 0, 0)))
  case order {
    order.Eq -> a == b
    order.Gt -> a > b
    order.Lt -> a < b
  }
}
