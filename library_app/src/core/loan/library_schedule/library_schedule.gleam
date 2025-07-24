import gleam/list
import gleam/order
import gleam/result

import core/shared/types/date
import core/shared/types/specify_schedule

pub fn find_due_date(
  candidate: date.Date,
  schedule_list: List(specify_schedule.SpecifySchedule),
) -> Result(date.Date, String) {
  list.range(0, 30)
  |> list.map(date.add_days(candidate, _))
  |> list.map(get_or_create_schedule(_, schedule_list))
  |> list.find(fn(schedule) {
    specify_schedule.is_open(schedule) && le(candidate, schedule.date)
  })
  |> result.map(fn(it) { it.date })
  |> result.map_error(fn(_) { 
    "30日以内に開館日が見つかりません。管理者にお問い合わせください。" 
  })
}

fn get_or_create_schedule(
  date: date.Date,
  schedule_list: List(specify_schedule.SpecifySchedule),
) -> specify_schedule.SpecifySchedule {
  let schedule = {
    use schedule <- list.find(schedule_list)
    schedule.date == date
  }
  schedule
  |> result.unwrap(specify_schedule.with_date(date))
}

pub fn le(a: date.Date, b: date.Date) -> Bool {
  date.compare(a, order.Lt, b) || date.compare(a, order.Eq, b)
}
