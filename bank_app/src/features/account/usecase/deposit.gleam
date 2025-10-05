import gleam/result
import shared/uuid

import features/account/domain/aggregate
import features/account/usecase/error
import features/account/usecase/port

pub fn deposit(
  aggregate_id: uuid.Generate,
  load_events: port.LoadEvents,
  append_events: port.AppendEvents,
) -> Result(aggregate.Counter, error.AppError) {
  let id = aggregate_id()
  use events <- result.try(load_events(id))

  let current = aggregate.new() |> aggregate.replay(events)
  let event = aggregate.Upped
  use _ <- result.try(append_events(id, [event]))

  aggregate.handle(current, event) |> Ok()
}
