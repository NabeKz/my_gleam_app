pub type Reply {
  Reply(author: String, content: String, created_at: String)
}

pub opaque type TicketId {
  TicketId(value: String)
}

pub fn from_string(s: String) -> TicketId {
  TicketId(s)
}

pub fn to_string(s: TicketId) -> String {
  s.value
}
