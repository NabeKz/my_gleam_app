import app/ticket/domain
import gleam/json
import gleam/list

pub type Dto {
  Dto(id: String, title: String, status: String)
}

pub type Output =
  fn() -> json.Json

pub fn register(event: domain.TicketListed) -> Output {
  fn() { event() |> invoke() |> deserialize() }
}

fn invoke(items: List(domain.Ticket)) -> List(Dto) {
  items
  |> list.map(fn(item) {
    Dto(
      id: item.id |> domain.decode,
      title: item.title,
      status: to_string(item.status),
    )
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

fn deserialize(items: List(Dto)) -> json.Json {
  json.array(items, fn(item) {
    json.object([
      #("id", json.string(item.id)),
      #("title", json.string(item.title)),
      #("status", json.string(item.status)),
    ])
  })
}
