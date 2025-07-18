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
