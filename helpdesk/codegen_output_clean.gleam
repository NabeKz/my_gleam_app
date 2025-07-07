// Generated from Atlas schema (management tables excluded)
import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/string

// === TYPE DEFINITIONS ===

pub type Tickets {
  Tickets(
    id: Option(Int),
    title: String,
    description: String,
    status: String,
    created_at: String,
  )
}

pub fn tickets_decoder() -> decode.Decoder(Tickets) {
  use id <- decode.field(0, decode.optional(decode.int))
  use title <- decode.field(1, decode.string)
  use description <- decode.field(2, decode.string)
  use status <- decode.field(3, decode.string)
  use created_at <- decode.field(4, decode.string)

  decode.success(Tickets(
    id: id,
    title: title,
    description: description,
    status: status,
    created_at: created_at,
  ))
}

// === CRUD FUNCTIONS ===

pub type TicketsInsert {
  TicketsInsert(
    title: String,
    description: String,
    status: String,
    created_at: String,
  )
}

pub fn insert_tickets(data: TicketsInsert) -> String {
  "INSERT INTO tickets (title, description, status, created_at)"
  <> " VALUES (?, ?, ?, ?)"
}

pub fn insert_tickets_values(data: TicketsInsert) -> List(String) {
  [data.title, data.description, data.status, data.created_at]
}

pub type TicketsUpdate {
  TicketsUpdate(
    title: String,
    description: String,
    status: String,
    created_at: String,
  )
}

pub fn update_tickets(id: Int, data: TicketsUpdate) -> String {
  "UPDATE tickets SET title = ?, description = ?, status = ?, created_at = ?"
  <> " WHERE id = ?"
}

pub fn update_tickets_values(id: Int, data: TicketsUpdate) -> List(String) {
  [
    data.title,
    data.description,
    data.status,
    data.created_at,
    int.to_string(id),
  ]
}

pub fn delete_tickets(id: Int) -> String {
  "DELETE FROM tickets WHERE id = ?"
}

pub fn delete_tickets_values(id: Int) -> List(String) {
  [int.to_string(id)]
}
