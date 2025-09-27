import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}

pub type Journal(t) {
  Journal(id: String, event_type: String, event_data: t, version: Int)
}

pub type Store

pub type EventStore {
  EventStore(events: Dict(String, List(Journal(Dynamic))))
}

pub fn new() -> EventStore {
  EventStore(events: dict.new())
}

pub fn apply(store: Store, message: t) {
  todo
}
