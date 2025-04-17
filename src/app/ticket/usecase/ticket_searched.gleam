import gleam/dynamic
import gleam/dynamic/decode
import gleam/json
import gleam/result

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

pub fn invoke(
  params: String,
  event: domain.TicketSearched,
) -> Result(json.Json, ErrorMessage) {
  let result = {
    use ticket_id <- result.try(params |> validate_params())

    case event(ticket_id) {
      Ok(ticket) -> Ok(ticket)
      Error(_) -> Error(NotFound)
    }
  }

  case result {
    Ok(ticket) -> Ok(ticket |> deserialize)
    Error(err) -> Error(err)
  }
}

fn validate_params(params: String) -> Result(domain.TicketId, ErrorMessage) {
  let value = params |> dynamic.from
  case decode.run(value, decode_ticket_id()) {
    Ok(ticket_id) -> Ok(ticket_id)
    Error(_) -> Error(InvalidPath)
  }
}

fn decode_ticket_id() -> decode.Decoder(domain.TicketId) {
  use id <- decode.field("id", decode.string)
  id
  |> domain.ticket_id()
  |> decode.success()
}

fn deserialize(item: domain.Ticket) -> json.Json {
  json.object([
    #("id", json.string(item.id |> domain.decode)),
    #("title", json.string(item.title)),
    #("description", json.string(item.description)),
    #("status", json.string(item.status |> to_string)),
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
