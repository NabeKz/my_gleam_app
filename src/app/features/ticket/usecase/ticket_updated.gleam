import app/features/ticket/domain/ticket_status
import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/result
import lib/date_time

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
  let result = {
    let ticket_id = id |> domain.ticket_id
    case searched(ticket_id) {
      Ok(ticket) -> Ok(ticket)
      Error(_) -> Error("NotFound")
    }
  }

  let form = {
    use dto <- result.try(decode.run(form, decode_ticket()))
    use converted <- result.try(dto |> convert())

    converted
    |> Ok()
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

fn decode_ticket() -> decode.Decoder(Dto) {
  use title <- decode.field("title", decode.string)
  use description <- decode.field("description", decode.string)
  decode.success(Dto(title:, description:))
}

fn convert(
  dto: Dto,
) -> Result(domain.TicketWriteModel, List(decode.DecodeError)) {
  domain.TicketWriteModel(
    title: dto.title,
    description: dto.description,
    status: ticket_status.Open,
    created_at: date_time.now() |> date_time.to_string(),
  )
  |> Ok()
}
