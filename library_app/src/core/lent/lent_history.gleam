import gleam/dict
import gleam/list

import core/lent/events
import core/lent/lent_command
import core/lent/lent_state

pub type LentHistory {
  LentHistory(
    book_id: String,
    events: List(events.LentEvent),
    current_state: lent_state.LentState,
  )
}

pub fn get_lent_history(
  book_id: String,
  get_events: lent_command.GetEventsByBook,
) -> LentHistory {
  let events = book_id |> get_events()
  let current_state = lent_state.calculate_lent_state(book_id, events)
  LentHistory(book_id:, events:, current_state:)
}

pub fn get_current_lents(
  get_all_events: fn() -> List(events.LentEvent),
) -> List(#(String, lent_state.LentState)) {
  get_all_events()
  |> list.group(events.get_book_id)
  |> dict.to_list()
  |> list.map(fn(group) {
    let #(book_id, events) = group
    let state = lent_state.calculate_lent_state(book_id, events)
    #(book_id, state)
  })
  |> list.filter(fn(item) {
    case item.1 {
      lent_state.Lend(..) -> True
      lent_state.Available -> False
    }
  })
}
