import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/result

import app/features/ticket/domain
import app/features/ticket/domain/ticket_status

pub type Dto {
  Dto(title: String, description: String)
}

pub type ErrorMessage

pub type Body {
  FormData(dict.Dict(String, String))
  Json(dynamic.Dynamic)
}

pub type Workflow =
  fn(String) -> fn(dynamic.Dynamic) -> Result(domain.TicketId, List(String))

pub fn invoke(
  id: String,
  searched: domain.TicketSearched,
  updated: domain.TicketUpdated,
) {
  invoke2(id, _, searched, updated)
}

pub fn invoke2(
  id: String,
  form: dynamic.Dynamic,
  searched: domain.TicketSearched,
  updated: domain.TicketUpdated,
) -> Result(domain.TicketId, List(String)) {
  let ticket = {
    let ticket_id = id |> domain.ticket_id
    case searched(ticket_id) {
      Ok(ticket) -> Ok(ticket)
      Error(_) -> Error("NotFound")
    }
  }

  let dto = {
    use dto <- result.try(decode.run(form, decode_ticket()))

    dto
    |> Ok()
  }

  let ticket = case ticket, dto {
    Ok(ticket), Ok(dto) -> partial_update(ticket, dto) |> Ok()
    _, _ -> Error("failure")
  }

  let result = case ticket {
    Ok(value) -> updated(value) |> Ok()
    Error(_) -> Error("Invalid")
  }

  case result {
    Ok(value) -> Ok(value)
    Error(err) -> Error([err])
  }
}

fn decode_ticket() -> decode.Decoder(Dto) {
  use title <- decode.field("title", decode.string)
  use description <- decode.field("description", decode.string)
  decode.success(Dto(title:, description:))
}

fn partial_update(ticket: domain.Ticket, dto: Dto) -> domain.Ticket {
  domain.Ticket(..ticket, title: dto.title, description: dto.description)
}
