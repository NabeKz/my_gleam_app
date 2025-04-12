import app/ticket/domain.{new_ticket}

pub fn new() -> domain.TicketRepository {
  let items = [
    new_ticket(id: "1", title: "hoge", created_at: "#FFF"),
    new_ticket(id: "2", title: "fuga", created_at: "#999"),
    new_ticket(id: "3", title: "piyo", created_at: "#000"),
  ]

  domain.TicketRepository(list: fn() { items }, create: fn(_) { todo })
}
