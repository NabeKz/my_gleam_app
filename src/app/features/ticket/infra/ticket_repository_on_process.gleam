import app/features/ticket/domain
import gleam/erlang/process.{type Subject}
import gleam/int
import gleam/list
import gleam/otp/actor
import gleam/result
import lib/date_time

const max_history = 10

pub type MockRepo(a) {
  MockRepo(subject: Subject(Message(a)))
}

pub type MockRepository {
  MockRepository(
    list: domain.TicketListed,
    create: domain.TicketCreated,
    find: domain.TicketSearched,
    delete: domain.TicketDeleted,
    update: domain.TicketUpdated,
  )
}

pub type Message(a) {
  Push(a, Subject(Nil))
  GetId(Subject(Int))
  GetAll(Subject(List(a)))
  Delete(List(a), Subject(Nil))
  Update(List(a), Subject(Nil))
  Clear(Subject(Nil))
}

pub fn new() -> MockRepository {
  let items =
    [
      domain.new_ticket(
        id: "1",
        title: "hoge",
        description: "",
        created_at: date_time.now() |> date_time.to_string(),
      ),
      domain.new_ticket(
        id: "2",
        title: "fuga",
        description: "",
        created_at: date_time.now() |> date_time.to_string(),
      ),
      domain.new_ticket(
        id: "3",
        title: "piyo",
        description: "",
        created_at: date_time.now() |> date_time.to_string(),
      ),
    ]
    |> result.values

  let id = items |> list.length |> int.add(1)
  let assert Ok(subject) = actor.start(#(id, items), handle_message)

  MockRepository(
    list: fn(_) { process.call(subject, GetAll, 1000) |> list.reverse },
    create: fn(item: domain.TicketWriteModel) {
      let id = process.call(subject, GetId, 1000) |> int.to_string()
      let model = domain.to(item, domain.ticket_id(id))
      let _ = process.call(subject, Push(model, _), 1000)
      model.id
    },
    find: fn(id: domain.TicketId) {
      process.call(subject, GetAll, 1000)
      |> list.find(fn(item) { item.id == id })
      |> result.map_error(fn(_) { "not found" })
    },
    delete: fn(id: domain.TicketId) {
      let items = process.call(subject, GetAll, 1000)
      let items = list.filter(items, fn(item) { item.id != id })
      process.call(subject, Delete(items, _), 1000)
      Ok(Nil)
    },
    update: fn(item: domain.Ticket) {
      let items = process.call(subject, GetAll, 1000)
      let items =
        list.map(items, fn(x) {
          case x.id == item.id {
            True -> item
            False -> x
          }
        })
      process.call(subject, Update(items, _), 1000)
      item.id
    },
  )
}

fn handle_message(
  message: Message(a),
  state: #(Int, List(a)),
) -> actor.Next(Message(a), #(Int, List(a))) {
  case message {
    Push(item, reply_to) -> {
      let id = state.0 + 1
      let state = case list.length(state.1) >= max_history {
        True -> {
          #(id, [item, ..list.take(state.1, max_history)])
        }
        False -> #(id, [item, ..state.1])
      }
      process.send(reply_to, Nil)
      actor.continue(state)
    }
    GetId(reply_to) -> {
      process.send(reply_to, state.0)
      actor.continue(state)
    }
    GetAll(reply_to) -> {
      process.send(reply_to, state.1)
      actor.continue(state)
    }
    Delete(items, reply_to) -> {
      process.send(reply_to, Nil)
      actor.continue(#(state.0, items))
    }
    Update(items, reply_to) -> {
      process.send(reply_to, Nil)
      actor.continue(#(state.0, items))
    }
    Clear(reply_to) -> {
      process.send(reply_to, Nil)
      actor.continue(#(0, []))
    }
  }
}
