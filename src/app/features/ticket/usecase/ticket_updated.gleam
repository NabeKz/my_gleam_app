import gleam/dict
import gleam/dynamic

import app/features/ticket/domain

pub type Dto {
  Dto(title: String, description: String)
}

pub type ErrorMessage

pub type Body {
  FormData(dict.Dict(String, String))
  Json(dynamic.Dynamic)
}

pub type Workflow =
  fn(String) -> Result(domain.TicketId, List(String))

pub fn invoke(
  id: String,
  searched: domain.TicketSearched,
  updated: domain.TicketUpdated,
) -> Result(domain.TicketId, List(String)) {
  let result = {
    let ticket_id = id |> domain.ticket_id
    case searched(ticket_id) {
      Ok(ticket) -> Ok(ticket)
      Error(_) -> Error("NotFound")
    }
  }

  let result = case result {
    Ok(value) -> updated(value) |> Ok()
    Error(_) -> Error("Invalid")
  }

  case result {
    Ok(value) -> Ok(value)
    Error(err) -> Error([err])
  }
}
