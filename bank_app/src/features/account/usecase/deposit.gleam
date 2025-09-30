import features/account/domain/aggregate as domain
import features/account/usecase/port

pub fn deposit(
  aggregate_id: String,
  event: domain.CounterEvent,
  load_events: port.LoadEvents,
  append_events: port.AppendEvents,
) {
  case load_events(aggregate_id) {
    Ok(events) -> {
      let current = domain.new() |> domain.replay(events)

      case append_events(aggregate_id, [event]) {
        Ok(_) -> {
          let next = domain.handle(current, event)

          Ok(next)
        }
        Error(error) -> Error(error)
      }
    }
    Error(error) -> Error(error)
  }
}
