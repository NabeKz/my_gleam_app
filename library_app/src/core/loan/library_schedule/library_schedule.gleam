import gleam/list

import core/shared/library_schedule/specify_schedule
import core/shared/types/date

pub fn is_open_day(date: date.Date) {
  todo
}

pub fn is_weekday_open(date: date.Date) {
  todo
}

pub fn find_due_date(
  candidate: date.Date,
  schedule_list: List(specify_schedule.SpecifySchedule),
) {
  let due_date = {
    use it <- list.find(schedule_list)
    it.date == candidate
  }
  case due_date {
    Ok(schedule) -> schedule.date
    Error(_) -> candidate
  }
}

pub fn calculate_due_date(
  loan_date: date.Date,
  schedule_list: List(specify_schedule.SpecifySchedule),
) {
  todo
}
