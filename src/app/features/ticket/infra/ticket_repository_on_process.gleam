import gleam/erlang/process.{type Subject}
import gleam/list
import gleam/otp/actor

pub type MockRepository(a) {
  MockRepository(subject: Subject(Message(a)))
}

pub type Message(a) {
  Push(a, Subject(Nil))
  GetAll(Subject(List(a)))
  Clear(Subject(Nil))
  Length(Subject(Int))
}

pub fn new() -> MockRepository(a) {
  let assert Ok(subject) = actor.start([], handle_message)
  MockRepository(subject)
}

pub fn push(repo: MockRepository(a), item: a) -> Nil {
  let _ = process.call(repo.subject, Push(item, _), 1000)
  Nil
}

pub fn get_all(repo: MockRepository(a)) -> List(a) {
  let items = process.call(repo.subject, GetAll, 1000)
  list.reverse(items)
}

pub fn clear(repo: MockRepository(a)) -> Nil {
  let _ = process.call(repo.subject, Clear, 1000)
  Nil
}

pub fn length(repo: MockRepository(a)) -> Int {
  let count = process.call(repo.subject, Length, 1000)
  count
}

fn handle_message(
  message: Message(a),
  state: List(a),
) -> actor.Next(Message(a), List(a)) {
  case message {
    Push(item, reply_to) -> {
      process.send(reply_to, Nil)
      actor.continue([item, ..state])
    }
    GetAll(reply_to) -> {
      process.send(reply_to, state)
      actor.continue(state)
    }
    Clear(reply_to) -> {
      process.send(reply_to, Nil)
      actor.continue([])
    }
    Length(reply_to) -> {
      process.send(reply_to, list.length(state))
      actor.continue(state)
    }
  }
}
