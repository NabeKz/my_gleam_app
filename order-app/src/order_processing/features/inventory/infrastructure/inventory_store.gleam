import gleam/dict.{type Dict}
import gleam/int
import gleam/list

import order_processing/features/inventory/domain/core/events.{type InventoryEvent}

/// 保存された在庫イベント
pub type StoredInventoryEvent {
  StoredInventoryEvent(
    product_id: String,
    event_type: String,
    sequence_number: Int,
    event_data: InventoryEvent,
  )
}

/// 在庫イベントストア（インメモリ実装）
pub type InventoryStore {
  InventoryStore(events: Dict(String, List(StoredInventoryEvent)))
}

/// 新しい在庫イベントストアを作成
pub fn new() -> InventoryStore {
  InventoryStore(events: dict.new())
}

/// イベントを保存（楽観的排他制御付き）
pub fn save_events(
  store: InventoryStore,
  product_id: String,
  events: List(InventoryEvent),
  expected_version: Int,
) -> Result(InventoryStore, String) {
  case events {
    [] -> Ok(store) // 空のイベントリストの場合はそのまま返す
    _ -> {
      // 現在のバージョンをチェック
      let current_version = get_version(store, product_id)
      
      case current_version == expected_version {
        True -> {
          // 新しいイベントをStoredInventoryEventに変換
          let stored_events = events
            |> list.index_map(fn(event, index) {
              StoredInventoryEvent(
                product_id: product_id,
                event_type: get_event_type(event),
                sequence_number: expected_version + index + 1,
                event_data: event,
              )
            })
          
          // 既存のイベントリストに追加
          let existing_events = case dict.get(store.events, product_id) {
            Ok(events) -> events
            Error(_) -> []
          }
          
          let updated_events = list.append(existing_events, stored_events)
          let updated_store = InventoryStore(
            events: dict.insert(store.events, product_id, updated_events),
          )
          
          Ok(updated_store)
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

/// 商品のイベントを取得
pub fn get_events(
  store: InventoryStore,
  product_id: String,
) -> Result(List(InventoryEvent), String) {
  case dict.get(store.events, product_id) {
    Ok(stored_events) -> {
      let events =
        stored_events
        |> list.map(fn(stored) { stored.event_data })
      Ok(events)
    }
    Error(_) -> Error("Product not found")
  }
}

/// 商品の現在のバージョンを取得
pub fn get_version(store: InventoryStore, product_id: String) -> Int {
  case dict.get(store.events, product_id) {
    Ok(stored_events) -> list.length(stored_events)
    Error(_) -> 0
  }
}

/// すべてのイベントを取得（デバッグ用）
pub fn get_all_events(store: InventoryStore) -> List(StoredInventoryEvent) {
  store.events
  |> dict.values()
  |> list.flatten()
}

// ヘルパー関数

/// イベントの型名を取得
fn get_event_type(event: InventoryEvent) -> String {
  case event {
    events.ProductAddedToInventory(..) -> "ProductAddedToInventory"
    events.StockReceived(..) -> "StockReceived"
    events.StockReserved(..) -> "StockReserved"
    events.StockReservationReleased(..) -> "StockReservationReleased"
    events.StockIssued(..) -> "StockIssued"
    events.StockAdjusted(..) -> "StockAdjusted"
    events.StockShortage(..) -> "StockShortage"
  }
}