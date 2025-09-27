import features/account/domain
import shared/event_store

pub fn deposit(
  message: domain.CounterEvent,
  get_counter: domain.GetCounter,
  store: event_store.Store,
) {
  let id = "a"

  case get_counter(id) {
    Ok(counter) -> {
      counter
      |> domain.handle_message(message)
      |> event_store.apply(store, _)

      Ok(Nil)
    }
    Error(error) -> Error(error)
  }
}
