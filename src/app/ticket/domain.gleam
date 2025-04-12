pub type TicketStatus {
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
    status: TicketStatus,
    created_at: String,
    replies: List(Reply),
  )
}

pub opaque type TicketId {
  TicketId(value: String)
}

pub type TicketListed =
  fn() -> List(Ticket)

pub type TicketCreated =
  fn(Ticket) -> TicketId

pub type TicketUpdated =
  fn() -> List(Ticket)

pub type TicketRepository {
  TicketRepository(list: TicketListed, create: TicketCreated)
}

pub fn new_ticket(
  id id: String,
  title title: String,
  created_at created_at: String,
) -> Ticket {
  Ticket(
    id: id,
    title: title,
    description: "",
    status: Open,
    created_at:,
    replies: [],
  )
}

pub fn ticket_id(s: String) -> TicketId {
  TicketId(s)
}
