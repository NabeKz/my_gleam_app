pub type TicketStatus {
  Open
  Progress
  Done
  Close
}

pub fn from_string(value: String) -> Result(TicketStatus, String) {
  case value {
    "open" -> Ok(Open)
    "close" -> Ok(Close)
    "progress" -> Ok(Progress)
    "done" -> Ok(Done)
    _ -> Error(value <> " is invalid status")
  }
}

pub fn to_string(value: TicketStatus) -> String {
  case value {
    Open -> "open"
    Close -> "close"
    Progress -> "progress"
    Done -> "done"
  }
}
