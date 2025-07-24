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

pub fn with_date(date: date.Date) {
  let schedule_type = {
    case date.get_weekday(date) {
      date.Monday -> Close
      _ -> Open
    }
  }
  SpecifySchedule(schedule_type:, date:)
}

pub fn is_open(schedule: SpecifySchedule) -> Bool {
  schedule.schedule_type == Open
}

pub fn is_close(schedule: SpecifySchedule) -> Bool {
  schedule.schedule_type == Close
}
