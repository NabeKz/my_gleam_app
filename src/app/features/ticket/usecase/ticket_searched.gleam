import gleam/json

import app/features/ticket/domain
import app/features/ticket/domain/ticket_status

pub type Dto {
  Dto(id: String, title: String, status: String)
}

pub type ErrorMessage {
  InvalidPath
  NotFound
}

pub type Output =
  fn(String) -> Result(json.Json, List(ErrorMessage))

pub fn invoke(
  id: String,
  event: domain.TicketSearched,
) -> Result(json.Json, List(ErrorMessage)) {
  let result = {
    let ticket_id = id |> domain.ticket_id

    case event(ticket_id) {
      Ok(ticket) -> Ok(ticket)
      Error(_) -> Error(NotFound)
    }
  }

  case result {
    Ok(ticket) -> Ok(ticket |> deserialize)
    Error(err) -> Error([err])
  }
}

fn deserialize(item: domain.Ticket) -> json.Json {
  json.object([
    #("id", json.string(item.id |> domain.decode)),
    #("title", json.string(item.title)),
    #("description", json.string(item.description)),
    #("status", json.string(item.status |> ticket_status.to_string)),
    #("created_at", json.string(item.created_at)),
  ])
}
