import gleam/dynamic
import gleam/dynamic/decode
import gleam/result
import lib/date_time

import app/ticket/domain

pub type Dto {
  Dto(title: String, description: String)
}

pub type Output =
  fn(dynamic.Dynamic) -> Result(domain.TicketId, List(decode.DecodeError))

pub fn invoke(
  event: domain.TicketCreated,
  json: dynamic.Dynamic,
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
    status: domain.Open,
    created_at: date_time.now() |> date_time.to_string(),
  )
  |> Ok()
}
// fn to_status(
//   value: String,
// ) -> Result(domain.TicketStatus, List(decode.DecodeError)) {
//   case value {
//     "open" -> Ok(domain.Open)
//     "done" -> Ok(domain.Done)
//     "close" -> Ok(domain.Close)
//     "progress" -> Ok(domain.Progress)
//     _ -> {
//       decode.decode_error("not exist in ticket status", dynamic.from(value))
//       |> Error()
//     }
//   }
// }
