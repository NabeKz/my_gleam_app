import gleam/int
import gleam/list
import gleam/result
import lib/storage

import app/features/ticket/domain.{new_ticket}

const table = "tickets"

const table_index = "tickets_index"

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
  storage.init(table_index)
  {
    use it <- list.each(mock_items())
    storage.put(table, #(it.id, it))
  }
  storage.put(table_index, #("index", mock_items() |> list.length()))

  MockRepository(
    list: fn(_) {
      use it <- list.map(storage.all(table))
      it.1
    },
    create: fn(item: domain.TicketWriteModel) {
      let index =
        storage.all(table_index)
        |> list.first()
        |> result.unwrap(#("index", 0))
      let item =
        index.1
        |> int.add(1)
        |> int.to_string()
        |> domain.ticket_id()
        |> domain.to(item, _)

      storage.put(table, #(item.id, item))
      item.id
    },
    find: fn(id: domain.TicketId) -> Result(domain.Ticket, String) {
      use #(_, value) <- result.try(storage.get(table, id))
      value |> Ok()
    },
    delete: fn(id: domain.TicketId) {
      storage.delete(table, id)
      |> Ok()
    },
    update: fn(item: domain.Ticket) {
      storage.put(table, #(item.id, item))
      item.id
    },
  )
}
