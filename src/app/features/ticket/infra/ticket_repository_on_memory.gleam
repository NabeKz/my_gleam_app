import gleam/int
import gleam/list

import app/features/ticket/domain.{new_ticket}

pub type MockRepository {
  MockRepository(
    list: domain.TicketListed,
    create: domain.TicketCreated,
    find: domain.TicketSearched,
    delete: domain.TicketDeleted,
    update: domain.TicketUpdated,
  )
}

fn mock_items() {
  [
    new_ticket(title: "hoge", description: "", created_at: "2024-05-01"),
    new_ticket(title: "fuga", description: "", created_at: "2024-05-01"),
    new_ticket(title: "piyo", description: "", created_at: "2024-05-01"),
  ]
}

pub fn new(items: List(domain.Ticket)) -> MockRepository {
  let items = case items {
    [] -> {
      mock_items()
      |> list.map(fn(it) {
        let assert Ok(it) = it
        it
      })
    }
    _ -> items
  }

  MockRepository(
    list: fn(_) { items },
    create: fn(item: domain.TicketWriteModel) {
      let id =
        items
        |> list.length
        |> int.add(1)
        |> int.to_string
        |> domain.ticket_id

      let model = domain.to(item, id)
      let _ = list.append(items, [model])
      model.id
    },
    find: fn(id: domain.TicketId) {
      let item = list.find(items, fn(it) { it.id == id })

      case item {
        Ok(ticket) -> Ok(ticket)
        Error(_) -> Error("not found")
      }
    },
    delete: fn(id: domain.TicketId) {
      let _ = list.filter(items, fn(item) { item.id != id })
      Ok(Nil)
    },
    update: fn(item: domain.Ticket) { item.id },
  )
}
