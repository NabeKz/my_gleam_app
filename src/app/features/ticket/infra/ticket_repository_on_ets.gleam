import gleam/int
import gleam/result
import lib/storage

import app/features/ticket/domain.{new_ticket}

pub type MockRepository {
  MockRepository(
    list: domain.TicketListed,
    create: domain.TicketCreated,
    find: domain.TicketSearched,
    update: domain.TicketUpdated,
    delete: domain.TicketDeleted,
  )
}

fn mock_items() -> List(domain.Ticket) {
  [
    new_ticket(title: "hoge", description: "aaaaaa", created_at: "2024-05-01"),
    new_ticket(title: "fuga", description: "bbbbbb", created_at: "2024-05-01"),
    new_ticket(title: "piyo", description: "cccccc", created_at: "2024-05-01"),
  ]
  |> result.all()
  |> result.unwrap([])
}

pub fn new() -> MockRepository {
  let conn = {
    use it <- storage.conn("tickes", mock_items())
    it.id
  }

  MockRepository(
    list: fn(_) { conn.all() },
    create: fn(item: domain.TicketWriteModel) {
      let id = conn.get_next_id() |> int.to_string |> domain.ticket_id
      let item = id |> domain.to(item, _)
      conn.create(#(id, item))
    },
    find: fn(id: domain.TicketId) -> Result(domain.Ticket, String) {
      use #(_, value) <- result.try(conn.get(id))
      value |> Ok()
    },
    delete: fn(id: domain.TicketId) {
      conn.delete(id)
      |> Ok()
    },
    update: fn(item: domain.Ticket) {
      conn.put(#(item.id, item))
      item.id
    },
  )
}
