import features/account/usecase/port
import shared/db

pub fn load_events(_connection: db.Connection) -> port.LoadEvents {
  fn(_aggregate_id) { Ok([]) }
}

pub fn append_events(_connection: db.Connection) -> port.AppendEvents {
  fn(_aggregate_id, _events) { Ok(Nil) }
}
