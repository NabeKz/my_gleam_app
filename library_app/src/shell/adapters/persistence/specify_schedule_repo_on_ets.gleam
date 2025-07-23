import core/shared/specify_schedule/specify_schedule
import core/shared/types/date
import shell/shared/lib/ets

type SpecifyScheduleRepo =
  ets.Conn(String, specify_schedule.SpecifySchedule)

pub fn new() -> SpecifyScheduleRepo {
  ets.conn(
    [
      specify_schedule.SpecifySchedule(
        specify_schedule.Open,
        date.from(#(2025, 7, 1)),
      ),
      specify_schedule.SpecifySchedule(
        specify_schedule.Open,
        date.from(#(2025, 7, 1)),
      ),
    ],
    fn(it) { it.date |> date.to_string() },
  )
}

pub fn get_loan(
  date: date.Date,
  conn: SpecifyScheduleRepo,
) -> Result(specify_schedule.SpecifySchedule, String) {
  conn.get(date |> date.to_string())
}
