import gleeunit
import gleeunit/should

import core/shared/library_schedule/library_schedule
import core/shared/types/date

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn find_due_date_test() {
  let candidate = date.from(#(2025, 7, 1))
  let schedule_list = []

  library_schedule.calculate_due_date(candidate, schedule_list)
  |> should.equal(200)
}
