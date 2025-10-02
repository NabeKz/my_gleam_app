import gleeunit/should

import features/account/domain/aggregate
import features/account/usecase/deposit
import features/account/usecase/error

pub fn replays_history_and_applies_event_test() {
  let aggregate_id = "counter-123"

  let load_events = fn(id) {
    assert id == aggregate_id

    Ok([aggregate.Upped, aggregate.Upped, aggregate.Downed])
  }

  let append_events = fn(id, events) {
    assert id == aggregate_id
    assert events == [aggregate.Downed]

    Ok(Nil)
  }

  case
    deposit.deposit(aggregate_id, aggregate.Downed, load_events, append_events)
  {
    Ok(counter) -> {
      assert aggregate.value(counter) == 0

      Nil
    }
    Error(_) -> should.fail()
  }
}

pub fn load_failure_propagates_error_test() {
  let load_events = fn(_id) { Error(error.LoadFailed("boom")) }

  let append_events = fn(_id, _events) {
    should.fail()

    Ok(Nil)
  }

  case
    deposit.deposit("counter-1", aggregate.Upped, load_events, append_events)
  {
    Error(error.LoadFailed(_)) -> Nil
    _ -> should.fail()
  }
}

pub fn append_failure_propagates_error_test() {
  let load_events = fn(_id) { Ok([aggregate.Upped]) }

  let append_events = fn(_id, events) {
    assert events == [aggregate.Upped]

    Error(error.AppendFailed("db down"))
  }

  case
    deposit.deposit("counter-1", aggregate.Upped, load_events, append_events)
  {
    Error(error.AppendFailed(_)) -> Nil
    _ -> should.fail()
  }
}
