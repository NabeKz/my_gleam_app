import gleam/result

import features/account/application/error
import features/account/application/port
import features/account/domain/aggregate
import shared/uuid

pub fn deposit(
  aggregate_id: uuid.Generate,
  load_events: port.LoadEvents,
  append_events: port.AppendEvents,
) -> Result(port.AggregateContext(aggregate.Account), error.AppError) {
  let id = aggregate_id()
  use port.EventStream(events, version) <- result.try(load_events(id))

  let current =
    id
    |> aggregate.new()
    |> aggregate.replay(events)

  let event = aggregate.Upped
  use _ <- result.try(append_events(id, version, [event]))

  current
  |> aggregate.handle(event)
  |> fn(acc) { port.AggregateContext(acc, version + 1) }
  |> Ok
}

pub fn create(
  generate_id: uuid.Generate,
  append_events: port.AppendEvents,
) -> Result(port.AggregateContext(aggregate.Account), error.AppError) {
  let aggregate_id = generate_id()
  let account = aggregate_id |> aggregate.new()
  let created_event = aggregate.Created

  use _ <- result.try(append_events(aggregate_id, 0, [created_event]))

  account
  |> aggregate.handle(created_event)
  |> fn(acc) { port.AggregateContext(acc, 1) }
  |> Ok
}
