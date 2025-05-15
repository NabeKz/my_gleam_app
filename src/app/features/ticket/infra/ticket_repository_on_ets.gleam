import gleam/int
import gleam/list
import gleam/result
import lib/storage

import app/features/ticket/domain.{new_ticket}

const table = "tickets"

pub type MockRepository {
  MockRepository(
    list: domain.TicketListed,
    create: domain.TicketCreated,
    find: domain.TicketSearched,
    delete: domain.TicketDeleted,
  )
}

fn mock_items() -> List(domain.Ticket) {
  [
    new_ticket(
      id: "1",
      title: "hoge",
      description: "",
      created_at: "2024-05-01",
    ),
    new_ticket(
      id: "2",
      title: "fuga",
      description: "",
      created_at: "2024-05-01",
    ),
    new_ticket(
      id: "3",
      title: "piyo",
      description: "",
      created_at: "2024-05-01",
    ),
  ]
  |> result.all()
  |> result.unwrap([])
}

pub fn new() -> MockRepository {
  storage.init(table)
  {
    use it <- list.each(mock_items())
    storage.put(table, #(it.id, it))
  }

  MockRepository(
    list: fn(_) {
      use it <- list.map(storage.all(table))
      it.1
    },
    create: fn(item: domain.TicketWriteModel) {
      let item =
        storage.all(table)
        |> list.length()
        |> int.add(1)
        |> int.to_string()
        |> domain.ticket_id()
        |> domain.to(item, _)

      storage.put(table, #(item.id, item))
      item.id
    },
    find: fn(id: domain.TicketId) {
      use #(_, value) <- result.try(storage.get(table, id))
      value
    },
    delete: fn(id: domain.TicketId) {
      storage.delete(table, id)
      |> Ok()
    },
  )
}
