import core/shared/types/date

pub type GetSpecifySchedulesAfterCurrentDate =
  fn(date.Date) -> List(SpecifySchedule)

pub type SpecifySchedule {
  SpecifySchedule(schedule_type: ScheduleType, date: date.Date)
}

pub type ScheduleType {
  Open
  Close
}

pub fn is_close(schedule: SpecifySchedule) -> Bool {
  case schedule.schedule_type {
    Open -> True
    Close -> False
  }
}
