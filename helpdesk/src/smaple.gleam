// Generated types for tickets table
import gleam/dynamic/decode
import gleam/option.{type Option}

pub type Tickets {
  Tickets(
  id: Option(Int),
  title: String,
  description: String,
  status: String,
  created_at: String
  )
}

pub fn tickets_decoder() -> decode.Decoder(Tickets) {
  use id <- decode.field(0, decode.optional(decode.int))
  use title <- decode.field(1, decode.string)
  use description <- decode.field(2, decode.string)
  use status <- decode.field(3, decode.string)
  use created_at <- decode.field(4, decode.string)

  decode.success(Tickets(id: id, title: title, description: description, status: status, created_at: created_at))
}
