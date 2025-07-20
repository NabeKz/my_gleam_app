import core/shared/types/date

pub type SpecifySchedule {
  SpecifySchedule(
    date: date.Date,
    schedule_type: ScheduleType,
    //
  )
}

pub type ScheduleType {
  Opened
  Closed
}
