import gleam/option.{type Option}

import lib/date_time
import lib/validator

import app/ticket/domain/ticket_status.{type TicketStatus, Open}

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

pub type ValidateSearchParams {
  ValidateSearchParams(
    status: Option(TicketStatus),
    created_at: Option(date_time.Date),
  )
}

pub type TicketListed =
  fn(ValidateSearchParams) -> List(Ticket)

pub type TicketCreated =
  fn(TicketWriteModel) -> TicketId

pub type TicketSearched =
  fn(TicketId) -> Result(Ticket, String)

pub type TicketUpdated =
  fn(TicketWriteModel) -> TicketId

pub type TicketDeleted =
  fn(TicketId) -> Result(Nil, String)

pub fn ticket_id(s: String) -> TicketId {
  TicketId(s)
}

pub fn decode(s: TicketId) -> String {
  s.value
}

pub fn new_ticket(
  id id: String,
  title title: String,
  description description: String,
  created_at created_at: String,
) -> Result(Ticket, List(String)) {
  let decode = {
    use id <- validator.field(
      validator.wrap("id", id)
      |> validator.required()
      |> validator.less_than(200),
    )
    use title <- validator.field(
      validator.wrap("title", title)
      |> validator.required()
      |> validator.less_than(200),
    )
    use created_at <- validator.field(
      validator.wrap("created_at", created_at)
      |> validator.required(),
    )

    Ticket(
      id: ticket_id(id),
      title: title,
      description:,
      status: Open,
      created_at:,
      replies: [],
    )
    |> validator.success()
  }

  validator.run(decode)
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
