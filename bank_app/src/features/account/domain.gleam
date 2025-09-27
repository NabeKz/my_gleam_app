pub type CounterEvent {
  Upped
  Downed
}

pub type Counter {
  Counter(value: Int)
}

type ID =
  String

pub type GetCounter =
  fn(ID) -> Result(Counter, String)

pub fn handle_message(counter: Counter, message: CounterEvent) -> Counter {
  case message {
    Upped -> Counter(counter.value + 1)
    Downed -> Counter(counter.value - 1)
  }
}

pub fn replay(counter: Counter, messages: List(CounterEvent)) -> Counter {
  case messages {
    [] -> counter
    [message, ..rest] -> {
      counter
      |> handle_message(message)
      |> replay(rest)
    }
  }
}
