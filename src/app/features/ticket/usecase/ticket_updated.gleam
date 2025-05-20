import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/result
import lib/date_time

import app/features/ticket/domain
import app/features/ticket/domain/ticket_status

pub type Dto {
  Dto(title: String, description: String)
}

pub type Body {
  FormData(dict.Dict(String, String))
  Json(dynamic.Dynamic)
}

pub type Workflow =
  fn(dynamic.Dynamic) -> Result(domain.TicketId, List(decode.DecodeError))

pub fn invoke(
  json: dynamic.Dynamic,
  event: domain.TicketCreated,
) -> Result(domain.TicketId, List(decode.DecodeError)) {
  let result = {
    use dto <- result.try(decode.run(json, decode_ticket()))
    use converted <- result.try(dto |> convert())

    converted
    |> event()
    |> Ok()
  }

  case result {
    Ok(value) -> Ok(value)
    Error(err) -> Error(err)
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
