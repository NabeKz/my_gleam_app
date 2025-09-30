pub type CounterEvent {
  Upped
  Downed
}

pub opaque type Counter {
  Counter(value: Int)
}

pub fn new() -> Counter {
  Counter(0)
}

pub fn handle(counter: Counter, message: CounterEvent) -> Counter {
  case message {
    Upped -> Counter(counter.value + 1)
    Downed -> Counter(counter.value - 1)
  }
}

pub fn replay(counter: Counter, events: List(CounterEvent)) -> Counter {
  case events {
    [] -> counter
    [message, ..rest] -> {
      counter
      |> handle(message)
      |> replay(rest)
    }
  }
}

pub fn value(self: Counter) -> Int {
  self.value
}
