import features/account/domain/aggregate
import features/account/usecase/port
import gleam/result

pub fn deposit(
  aggregate_id: String,
  event: aggregate.CounterEvent,
  load_events: port.LoadEvents,
  append_events: port.AppendEvents,
) {
  use events <- result.try(load_events(aggregate_id))

  let current = aggregate.new() |> aggregate.replay(events)
  use _ <- result.try(append_events(aggregate_id, [event]))

  aggregate.handle(current, event) |> Ok()
}
