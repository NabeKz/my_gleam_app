import gleam/option.{type Option, None, Some}
import gleam/time/calendar
import gleam/time/timestamp

import order_processing/core/shared/aggregate as shared_aggregate
import order_processing/features/ship_order/domain/core/aggregate
import order_processing/features/ship_order/domain/logic/command_handlers
import order_processing/features/ship_order/domain/logic/commands.{
  type OrderCommand,
}
import order_processing/features/ship_order/infrastructure/event_store.{
  type EventStore,
}

/// アプリケーションサービスの結果
pub type ServiceResult(t) {
  ServiceSuccess(result: t)
  ServiceFailure(error: String)
}

/// 注文サービス
pub type OrderService {
  OrderService(event_store: EventStore)
}

/// 新しい注文サービスを作成
pub fn new(event_store: EventStore) -> OrderService {
  OrderService(event_store: event_store)
}

/// 現在時刻を取得（便利関数）
pub fn get_current_date() -> calendar.Date {
  let now_timestamp = timestamp.system_time()
  let #(date, _) = timestamp.to_calendar(now_timestamp, calendar.utc_offset)
  date
}

/// コマンドを実行
pub fn execute_command(
  service: OrderService,
  command: OrderCommand,
  current_date: calendar.Date,
) -> ServiceResult(OrderService) {
  let order_id = commands.get_order_id(command)

  // イベントストアから現在の注文を復元
  let current_order = load_order(service.event_store, order_id)

  // コマンドハンドラーでコマンドを処理
  let command_result = route_command(current_order, command, current_date)

  case command_result {
    command_handlers.Success(events) -> {
      // イベントをイベントストアに保存
      let current_version = case current_order {
        Some(order) -> order.version
        None -> 0
      }

      case
        event_store.save_events(
          service.event_store,
          order_id,
          events,
          current_version,
        )
      {
        Ok(updated_store) -> {
          let updated_service = OrderService(event_store: updated_store)
          ServiceSuccess(updated_service)
        }
        Error(msg) -> ServiceFailure("Failed to save events: " <> msg)
      }
    }
    command_handlers.Failure(error) -> ServiceFailure(error)
  }
}

/// 注文を取得
pub fn get_order(
  service: OrderService,
  order_id: String,
) -> ServiceResult(Option(aggregate.Order)) {
  let order = load_order(service.event_store, order_id)
  ServiceSuccess(order)
}

/// 注文の現在のバージョンを取得
pub fn get_order_version(service: OrderService, order_id: String) -> Int {
  event_store.get_version(service.event_store, order_id)
}

// 内部ヘルパー関数

/// イベントストアから注文を復元
fn load_order(store: EventStore, order_id: String) -> Option(aggregate.Order) {
  case event_store.get_events(store, order_id) {
    Ok(events) -> {
      case events {
        [] -> None
        _ -> {
          let initial_order = aggregate.create_initial_order(order_id)
          Some(shared_aggregate.from_events(initial_order, events, aggregate.apply_event))
        }
      }
    }
    Error(_) -> None
  }
}

/// コマンドを適切なハンドラーにルーティング
fn route_command(
  current_order: Option(aggregate.Order),
  command: OrderCommand,
  current_date: calendar.Date,
) -> command_handlers.CommandResult {
  case command {
    commands.PlaceOrder(..) ->
      command_handlers.handle_place_order(current_order, command, current_date)

    commands.ValidateOrder(..) ->
      command_handlers.handle_validate_order(
        current_order,
        command,
        current_date,
      )

    commands.CalculatePrice(..) ->
      command_handlers.handle_calculate_price(
        current_order,
        command,
        current_date,
      )

    commands.CancelOrder(..) ->
      command_handlers.handle_cancel_order(current_order, command, current_date)

    // 他のコマンドは未実装
    commands.ProcessPayment(..) ->
      command_handlers.Failure("ProcessPayment not implemented yet")

    commands.PrepareShipping(..) ->
      command_handlers.Failure("PrepareShipping not implemented yet")

    commands.ShipOrder(..) ->
      command_handlers.Failure("ShipOrder not implemented yet")
  }
}
