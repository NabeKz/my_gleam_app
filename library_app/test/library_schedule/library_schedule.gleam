import gleeunit
import gleeunit/should

import core/loan/domain/library_schedule/library_schedule
import core/shared/types/date
import core/shared/types/specify_schedule

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn find_due_date_test() {
  let candidate = date.from(#(2025, 7, 1))
  let schedule_list = []

  library_schedule.find_due_date(candidate, schedule_list)
  |> should.equal(date.from(#(2025, 7, 1)) |> Ok)
}

pub fn find_due_date_next_test() {
  let candidate = date.from(#(2025, 7, 1))
  let schedule_list = [
    specify_schedule.SpecifySchedule(
      specify_schedule.Close,
      date.from(#(2025, 7, 1)),
    ),
  ]

  library_schedule.find_due_date(candidate, schedule_list)
  |> should.equal(date.from(#(2025, 7, 2)) |> Ok)
}
