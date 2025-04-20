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
  fn(String) -> Result(json.Json, ErrorMessage)

//
pub fn invoke(
  id: String,
  event: domain.TicketDeleted,
) -> Result(json.Json, ErrorMessage) {
  let result = {
    let ticket_id = id |> domain.ticket_id

    case event(ticket_id) {
      Ok(ticket) -> Ok(ticket)
      Error(_) -> Error(NotFound)
    }
  }

  case result {
    Ok(_) -> Ok(json.null())
    Error(err) -> Error(err)
  }
}
