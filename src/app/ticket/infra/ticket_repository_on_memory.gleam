import app/ticket/domain.{new_ticket}

pub fn new() -> domain.TicketRepository {
  let items = [
    new_ticket(id: "1", title: "hoge", created_at: "2024-05-01"),
    new_ticket(id: "2", title: "fuga", created_at: "2024-05-01"),
    new_ticket(id: "3", title: "piyo", created_at: "2024-05-01"),
  ]

  domain.TicketRepository(list: fn() { items }, create: fn(_) { todo })
}
