import gleam/list

import core/lent/events

pub type LentState {
  Available
  Lend(renter_id: String)
}

// Event Sourcingの特徴として「任意の時点の状態を判定できる」必要があるため
// 状態を計算するロジックが必要
pub fn calculate_lent_state(
  book_id: String,
  events: List(events.LentEvent),
) -> LentState {
  events
  |> list.filter(fn(event) { events.is_same_book_id(event, book_id)})
  |> list.fold(Available, apply_event)
}

fn apply_event(_state: LentState, event: events.LentEvent) -> LentState {
  case event {
    events.BookLend(e) ->Lend(renter_id: e.renter_id)
    events.BookReturned(_) -> Available
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