import gleam/dynamic
import gleam/dynamic/decode
import gleam/result
import lib/date_time

import app/ticket/domain

pub type Dto {
  Dto(title: String, description: String, status: String)
}

pub type Output =
  fn(dynamic.Dynamic) -> Result(domain.TicketId, String)

pub fn invoke(
  event: domain.TicketCreated,
  json: dynamic.Dynamic,
) -> Result(domain.TicketId, String) {
  let result = {
    use dto <- result.try(decode.run(json, decode_ticket()))

    dto
    |> convert()
    |> event()
    |> Ok()
  }

  case result {
    Ok(value) -> Ok(value)
    Error(_) -> Error("error")
  }
}

fn decode_ticket() -> decode.Decoder(Dto) {
  use title <- decode.field("title", decode.string)
  use description <- decode.field("description", decode.string)
  use status <- decode.field("status", decode.string)
  decode.success(Dto(title:, description:, status:))
}

fn convert(dto: Dto) -> domain.TicketWriteModel {
  domain.TicketWriteModel(
    title: dto.title,
    description: dto.description,
    status: domain.Open,
    created_at: date_time.now() |> date_time.to_string(),
  )
}
