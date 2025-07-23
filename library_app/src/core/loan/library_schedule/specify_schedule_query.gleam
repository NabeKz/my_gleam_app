import core/shared/types/date
import core/shared/types/specify_schedule

pub fn get_specify_schedules_workflow(
  get_specify_schedules: specify_schedule.GetSpecifySchedulesAfterCurrentDate,
) -> specify_schedule.GetSpecifySchedulesAfterCurrentDate {
  fn(date: date.Date) { get_specify_schedules(date) }
}
