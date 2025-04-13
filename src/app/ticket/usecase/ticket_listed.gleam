import app/ticket/domain
import gleam/list

pub type Dto {
  Dto(id: String, title: String, status: String)
}

pub type Invoke =
  fn() -> List(Dto)

pub fn invoke(event: domain.TicketListed) -> List(Dto) {
  event()
  |> list.map(fn(item) {
    Dto(id: item.id, title: item.title, status: to_string(item.status))
  })
}

fn to_string(status: domain.TicketStatus) -> String {
  case status {
    domain.Open -> "open"
    domain.Progress -> "progress"
    domain.Close -> "close"
    domain.Done -> "done"
  }
}
