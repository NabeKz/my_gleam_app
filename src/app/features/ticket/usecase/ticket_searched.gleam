import gleam/json

import app/features/ticket/domain
import app/features/ticket/domain/ticket_status

pub type Dto {
  Dto(
    id: String,
    title: String,
    description: String,
    status: String,
    created_at: String,
  )
}

pub type ErrorMessage {
  InvalidPath
  NotFound
}

pub type Workflow =
  fn(String) -> Result(Dto, List(ErrorMessage))

pub fn invoke(
  id: String,
  event: domain.TicketSearched,
) -> Result(Dto, List(ErrorMessage)) {
  let result = {
    let ticket_id = id |> domain.ticket_id
    case event(ticket_id) {
      Ok(ticket) -> Ok(ticket)
      Error(_) -> Error(NotFound)
    }
  }

  case result {
    Ok(ticket) -> Ok(ticket |> decode)
    Error(err) -> Error([err])
  }
}

fn decode(item: domain.Ticket) -> Dto {
  Dto(
    id: item.id |> domain.decode,
    title: item.title,
    description: item.description,
    status: item.status |> ticket_status.to_string,
    created_at: item.created_at,
  )
}

pub fn deserialize(item: Dto) -> json.Json {
  json.object([
    #("id", json.string(item.id)),
    #("title", json.string(item.title)),
    #("description", json.string(item.description)),
    #("status", json.string(item.status)),
    #("created_at", json.string(item.created_at)),
  ])
}
