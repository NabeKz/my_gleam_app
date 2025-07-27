import core/shared/types/date
import core/shared/types/specify_schedule

pub type ScheduleRepository {
  ScheduleRepository(
    get_specify_schedules: fn(date.Date) -> List(specify_schedule.SpecifySchedule),
  )
}