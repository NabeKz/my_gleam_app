import gleam/option.{type Option}

import lib/date_time
import lib/validator

import app/features/ticket/domain/ticket_status.{type TicketStatus, Open}

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
    title: Option(String),
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
  fn(Ticket) -> TicketId

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
    // not use ver.
    // validator.field(
    //   validator.wrap("id", id)
    //     |> validator.required()
    //     |> validator.less_than(200),
    //   fn(id) {
    //     validator.field(
    //       validator.wrap("title", title)
    //         |> validator.required()
    //         |> validator.less_than(200),
    //       fn(title) {
    //         validator.field(
    //           validator.wrap("created_at", created_at)
    //             |> validator.required(),
    //           fn(created_at) {
    //             Ticket(
    //               id: ticket_id(id),
    //               title: title,
    //               description:,
    //               status: Open,
    //               created_at:,
    //               replies: [],
    //             )
    //             |> validator.success()
    //           },
    //         )
    //       },
    //     )
    //   },
    // )
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

pub fn update(
  ticket: Ticket,
  ticket_status: ticket_status.TicketStatus,
) -> Result(Ticket, String) {
  let status = case ticket.status, ticket_status {
    _, ticket_status.Done -> Error("invalid")
    _, status -> Ok(status)
  }
  case status {
    Ok(status) -> Ok(Ticket(..ticket, status:))
    Error(_) -> Error("invalid")
  }
}

