import app/features/ticket/domain/ticket_id
import gleam/dynamic/decode
import gleam/int
import gleam/list

import app/features/ticket/domain
import app/features/ticket/domain/ticket_status
import lib/db.{Eq}

const table_name = "tickets"

pub fn list(
  conn: db.Conn,
  params: domain.ValidateSearchParams,
) -> List(domain.Ticket) {
  let conditions =
    []
    |> list.append(db.maybe_condition(Eq("title", _), params.title, db.string))
    |> list.append(
      db.maybe_condition(Eq("status", _), params.status, fn(it) {
        it |> ticket_status.to_string |> db.string
      }),
    )

  let #(sql, values) = db.select_with_where(table_name, conditions)

  case db.query(sql, conn, values, decoder()) {
    Ok(value) -> value
    Error(error) -> {
      echo error
      []
    }
  }
}

pub fn create(
  conn: db.Conn,
  item: domain.TicketWriteModel,
) -> Result(Nil, db.Error) {
  let #(sql, values) =
    db.insert_with_values(table_name, [
      #("title", item.title |> db.string()),
      #("description", item.description |> db.string()),
      #("status", item.status |> ticket_status.to_string |> db.string()),
      #("created_at", item.created_at |> db.string()),
    ])

  db.exec(sql, conn, values)
}

pub fn find(
  conn: db.Conn,
  id: domain.TicketId,
) -> Result(domain.Ticket, db.ErrorMessage) {
  let sql = "select * from " <> table_name <> " where id = ? limit 1;"

  let result =
    db.query(sql, conn, [id |> ticket_id.to_string |> db.string], decoder())

  result |> db.handle_find_result
}

pub fn update(
  conn: db.Conn,
  id: domain.TicketId,
  item: domain.TicketWriteModel,
) -> Result(domain.Ticket, db.ErrorMessage) {
  let sql = "update " <> table_name <> " set "
  let sql = sql <> "
    title = ?,
    description = ?,
    status = ?,
    created_at = ?
    where id = ?
  "

  let result =
    db.query(
      sql,
      conn,
      [
        item.title |> db.string,
        item.description |> db.string,
        item.status |> ticket_status.to_string |> db.string,
        item.created_at |> db.string,
        id |> ticket_id.to_string |> db.string,
      ],
      decoder(),
    )

  result |> db.handle_find_result
}

pub fn delete(conn: db.Conn, id: domain.TicketId) -> Result(Nil, String) {
  let sql = "delete from " <> table_name <> " where id = ?"
  let result =
    db.query(
      sql,
      conn,
      [id |> ticket_id.to_string |> db.string],
      decode.success(Nil),
    )

  case result {
    Ok(_) -> Ok(Nil)
    Error(error) -> Error(error.message)
  }
}

fn id_decoder(value: Int) -> domain.TicketId {
  value |> int.to_string |> domain.ticket_id
}

// TODO: handling
fn status_decoder(value: String) -> ticket_status.TicketStatus {
  let assert Ok(status) = value |> ticket_status.from_string
  status
}

fn decoder() -> decode.Decoder(domain.Ticket) {
  use id <- decode.field(0, decode.int |> decode.map(id_decoder))
  use title <- decode.field(1, decode.string)
  use description <- decode.field(2, decode.string)
  use status <- decode.field(3, decode.string |> decode.map(status_decoder))
  use created_at <- decode.field(4, decode.string)

  decode.success(
    domain.Ticket(id:, title:, description:, status:, created_at:, replies: []),
  )
}
