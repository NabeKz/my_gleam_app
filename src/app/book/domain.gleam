pub type Status {
  Open
  Progress
  Done
  Close
}

pub type Reply {
  Reply(author: String, content: String, created_at: String)
}

pub type Ticket {
  Ticket(
    id: String,
    title: String,
    description: String,
    status: Status,
    created_at: String,
    replies: List(Reply),
  )
}

pub type TicketListDisplayed =
  fn() -> List(Ticket)

pub type TicketCreated =
  fn() -> List(Ticket)

pub type TicketUpdated =
  fn() -> List(Ticket)
