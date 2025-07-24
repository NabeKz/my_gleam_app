import gleam/list
import gleam/order

import core/shared/types/date
import core/shared/types/specify_schedule

pub fn is_open_day(date: date.Date) {
  todo
}

pub fn is_weekday_open(date: date.Date) {
  todo
}

pub fn find_due_date(
  candidate: date.Date,
  schedule_list: List(specify_schedule.SpecifySchedule),
) -> date.Date {
  let schedule_list =
    list.range(0, 7)
    |> list.map(date.add_days(candidate, _))
    |> list.map(fn(date) {
      let schedule =
        list.find(schedule_list, fn(schedule) { date == schedule.date })
      case schedule {
        Ok(schedule) -> schedule
        Error(_) -> specify_schedule.with_date(date)
      }
    })

  let due_date = {
    use schedule <- list.find(schedule_list)
    specify_schedule.is_open(schedule) && le(candidate, schedule.date)
  }

  case due_date {
    Ok(schedule) -> schedule.date
    Error(_) -> candidate
  }
}

pub fn le(a: date.Date, b: date.Date) -> Bool {
  date.compare(a, order.Lt, b) || date.compare(a, order.Eq, b)
}

pub fn calculate_due_date(
  loan_date: date.Date,
  schedule_list: List(specify_schedule.SpecifySchedule),
) {
  todo
}
