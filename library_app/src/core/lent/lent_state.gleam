import gleam/list

import core/lent/events

pub type LentState {
  Available
  Lend(renter_id: String)
}

pub fn calculate_lent_state(
  book_id: String,
  events: List(events.LentEvent),
) -> LentState {
  events
  |> list.filter(events.is_same_book_id(_, book_id))
  |> list.fold(Available, apply_event)
}

fn apply_event(_state: LentState, event: events.LentEvent) -> LentState {
  case event {
    events.BookLendEvent(lend_event) -> {
      Lend(renter_id: lend_event.renter_id)
    }
    events.BookReturnedEvent(_) -> Available
  }
}

pub fn is_available(state: LentState) -> Bool {
  case state {
    Available -> True
    Lend(..) -> False
  }
}

pub fn is_rented_by(state: LentState, renter_id: String) -> Bool {
  case state {
    Available -> False
    Lend(id) -> id == renter_id
  }
}
