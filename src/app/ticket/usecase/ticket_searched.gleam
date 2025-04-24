import gleam/json

import app/ticket/domain

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
    #("status", json.string(item.status |> to_string)),
    #("created_at", json.string(item.created_at)),
  ])
}

fn to_string(value: domain.TicketStatus) -> String {
  case value {
    domain.Open -> "open"
    domain.Done -> "done"
    domain.Close -> "close"
    domain.Progress -> "progress"
  }
}
