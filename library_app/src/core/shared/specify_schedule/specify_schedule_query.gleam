import core/shared/specify_schedule/specify_schedule
import core/shared/types/date

pub fn get_specify_schedules_workflow(
  get_specify_schedules: specify_schedule.GetSpecifySchedulesAfterCurrentDate,
) -> specify_schedule.GetSpecifySchedulesAfterCurrentDate {
  fn(date: date.Date) { get_specify_schedules(date) }
}
