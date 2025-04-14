pub type TicketStatus {
  Open
  Progress
  Done
  Close
}

pub type Reply {
  Reply(author: String, content: String, created_at: String)
}

pub opaque type TicketId {
  TicketId(value: String)
}

pub type Ticket {
  Ticket(
    id: TicketId,
    title: String,
    description: String,
    status: TicketStatus,
    created_at: String,
    replies: List(Reply),
  )
}

pub type TicketWriteModel {
  TicketWriteModel(
    title: String,
    description: String,
    status: TicketStatus,
    created_at: String,
  )
}

pub type TicketListed =
  fn() -> List(Ticket)

pub type TicketCreated =
  fn(TicketWriteModel) -> TicketId

pub type TicketUpdated =
  fn() -> List(Ticket)

pub fn ticket_id(s: String) -> TicketId {
  TicketId(s)
}

pub fn decode(s: TicketId) -> String {
  s.value
}

pub fn new_ticket(
  id id: String,
  title title: String,
  created_at created_at: String,
) -> Ticket {
  Ticket(
    id: ticket_id(id),
    title:,
    description: "",
    status: Open,
    created_at:,
    replies: [],
  )
}

pub fn to(item: TicketWriteModel, id: TicketId) -> Ticket {
  Ticket(
    id:,
    title: item.title,
    description: item.description,
    status: item.status,
    created_at: item.created_at,
    replies: [],
  )
}
