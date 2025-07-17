pub type LentState {
  Available
  Lend(renter_id: String)
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