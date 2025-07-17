import gleam/list

import core/shared/types/date
import core/lent/events

pub type LentState {
  Available
  Lend(renter_id: String)
}

// Event Sourcingの特徴として「任意の時点の状態を判定できる」必要があるため
// 状態を計算するロジックが必要
pub fn calculate_lent_state_at_time(
  initial_state: LentState,   
  events: List(events.LentEvent),
  target_time: date.Timestamp,
) -> LentState {
  events
  |> list.filter(fn(event) { events.event_timestamp(event).value <= target_time.value })
  |> list.fold(initial_state, apply_event)
}

fn apply_event(_state: LentState, event: events.LentEvent) -> LentState {
  case event {
    events.BookLendEvent(e) ->Lend(renter_id: e.renter_id)
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
// TODO: 延滞チェック