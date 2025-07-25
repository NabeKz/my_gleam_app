import core/shared/types/date
import core/shared/types/specify_schedule
import gleam/list
import shell/shared/lib/ets

type SpecifyScheduleRepo =
  ets.Conn(String, specify_schedule.SpecifySchedule)

pub fn new() -> SpecifyScheduleRepo {
  ets.conn(
    [
      specify_schedule.SpecifySchedule(
        specify_schedule.Open,
        date.from(#(2025, 7, 31)),
      ),
      specify_schedule.SpecifySchedule(
        specify_schedule.Open,
        date.from(#(2025, 8, 1)),
      ),
    ],
    fn(it) { it.date |> date.to_string() },
  )
}

pub fn get_specify_schedules(
  date: date.Date,
  conn: SpecifyScheduleRepo,
) -> List(specify_schedule.SpecifySchedule) {
  conn.all()
  |> list.filter(fn(it) { it.date == date })
}
