import app/ticket/domain.{new_ticket}
import gleam/int
import gleam/list

pub type MockRepository {
  MockRepository(
    list: domain.TicketListed,
    create: domain.TicketCreated,
    find: domain.TicketSearched,
  )
}

pub fn new() -> MockRepository {
  let items = [
    new_ticket(id: "1", title: "hoge", created_at: "2024-05-01"),
    new_ticket(id: "2", title: "fuga", created_at: "2024-05-01"),
    new_ticket(id: "3", title: "piyo", created_at: "2024-05-01"),
  ]

  MockRepository(
    list: fn() { items },
    create: fn(item: domain.TicketWriteModel) {
      let id =
        items
        |> list.length
        |> int.add(1)
        |> int.to_string
        |> domain.ticket_id

      let model = domain.to(item, id)
      list.append(items, [model])
      model.id
    },
    find: fn(id: domain.TicketId) {
      let item = list.find(items, fn(item) { item.id == id })

      case item {
        Ok(item) -> Ok(item)
        Error(_) -> Error("not found")
      }
    },
  )
}
