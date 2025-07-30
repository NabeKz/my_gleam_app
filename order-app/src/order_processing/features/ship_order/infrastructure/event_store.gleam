import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import order_processing/features/ship_order/domain/core/events.{type OrderEvent}

/// 保存されたイベント
pub type StoredEvent {
  StoredEvent(
    aggregate_id: String,
    event_type: String,
    event_data: OrderEvent,
    version: Int,
  )
}

/// インメモリイベントストア
pub type EventStore {
  EventStore(events: Dict(String, List(StoredEvent)))
}

/// 新しいイベントストアを作成
pub fn new() -> EventStore {
  EventStore(events: dict.new())
}

/// イベントを保存
pub fn save_events(
  store: EventStore,
  aggregate_id: String,
  events: List(OrderEvent),
  expected_version: Int,
) -> Result(EventStore, String) {
  case dict.get(store.events, aggregate_id) {
    Error(_) -> {
      // 新しいアグリゲート
      case expected_version == 0 {
        True -> {
          let stored_events =
            events
            |> list.index_map(fn(event, index) {
              StoredEvent(
                aggregate_id: aggregate_id,
                event_type: get_event_type(event),
                event_data: event,
                version: index + 1,
              )
            })

          let new_events_dict =
            dict.insert(store.events, aggregate_id, stored_events)
          Ok(EventStore(events: new_events_dict))
        }
        False -> Error("Expected version should be 0 for new aggregate")
      }
    }
    Ok(existing_events) -> {
      // 既存のアグリゲート
      let current_version = list.length(existing_events)
      case current_version == expected_version {
        True -> {
          let new_stored_events =
            events
            |> list.index_map(fn(event, index) {
              StoredEvent(
                aggregate_id: aggregate_id,
                event_type: get_event_type(event),
                event_data: event,
                version: expected_version + index + 1,
              )
            })

          let updated_events = list.append(existing_events, new_stored_events)
          let new_events_dict =
            dict.insert(store.events, aggregate_id, updated_events)
          Ok(EventStore(events: new_events_dict))
        }
        False ->
          Error(
            "Version mismatch. Expected: "
            <> int.to_string(expected_version)
            <> ", Actual: "
            <> int.to_string(current_version),
          )
      }
    }
  }
}

/// アグリゲートのイベントを取得
pub fn get_events(
  store: EventStore,
  aggregate_id: String,
) -> Result(List(OrderEvent), String) {
  case dict.get(store.events, aggregate_id) {
    Ok(stored_events) -> {
      let events =
        stored_events
        |> list.map(fn(stored) { stored.event_data })
      Ok(events)
    }
    Error(_) -> Error("Aggregate not found")
  }
}

/// アグリゲートの現在のバージョンを取得
pub fn get_version(store: EventStore, aggregate_id: String) -> Int {
  case dict.get(store.events, aggregate_id) {
    Ok(stored_events) -> list.length(stored_events)
    Error(_) -> 0
  }
}

/// すべてのイベントを取得（デバッグ用）
pub fn get_all_events(store: EventStore) -> List(StoredEvent) {
  store.events
  |> dict.values()
  |> list.flatten()
}

// ヘルパー関数

/// イベントの型名を取得
fn get_event_type(event: OrderEvent) -> String {
  case event {
    events.OrderPlaced(..) -> "OrderPlaced"
    events.OrderValidated(..) -> "OrderValidated"
    events.PriceCalculated(..) -> "PriceCalculated"
    events.PaymentProcessed(..) -> "PaymentProcessed"
    events.ShippingPrepared(..) -> "ShippingPrepared"
    events.OrderShipped(..) -> "OrderShipped"
    events.OrderCancelled(..) -> "OrderCancelled"
  }
}
