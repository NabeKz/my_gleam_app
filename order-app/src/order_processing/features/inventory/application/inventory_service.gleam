import gleam/option.{type Option, None, Some}
import gleam/time/calendar
import gleam/time/timestamp

import order_processing/features/inventory/domain/core/aggregate
import order_processing/features/inventory/domain/logic/command_handlers
import order_processing/features/inventory/domain/logic/commands.{type InventoryCommand}
import order_processing/features/inventory/infrastructure/inventory_store.{
  type InventoryStore,
}

/// アプリケーションサービスの結果
pub type ServiceResult(t) {
  ServiceSuccess(result: t)
  ServiceFailure(error: String)
}

/// 在庫サービス
pub type InventoryService {
  InventoryService(inventory_store: InventoryStore)
}

/// 新しい在庫サービスを作成
pub fn new(inventory_store: InventoryStore) -> InventoryService {
  InventoryService(inventory_store: inventory_store)
}

/// 現在時刻を取得（便利関数）
pub fn get_current_date() -> calendar.Date {
  let now_timestamp = timestamp.system_time()
  let #(date, _) = timestamp.to_calendar(now_timestamp, calendar.utc_offset)
  date
}

/// コマンドを実行
pub fn execute_command(
  service: InventoryService,
  command: InventoryCommand,
  current_date: calendar.Date,
) -> ServiceResult(InventoryService) {
  let product_id = commands.get_product_id(command)
  
  // イベントストアから現在の在庫アイテムを復元
  let current_item = load_inventory_item(service.inventory_store, product_id)
  
  // コマンドハンドラーでコマンドを処理
  let command_result = route_command(current_item, command, current_date)
  
  case command_result {
    command_handlers.Success(events) -> {
      // イベントをイベントストアに保存
      let current_version = case current_item {
        Some(item) -> item.version
        None -> 0
      }
      
      case inventory_store.save_events(service.inventory_store, product_id, events, current_version) {
        Ok(updated_store) -> {
          let updated_service = InventoryService(inventory_store: updated_store)
          ServiceSuccess(updated_service)
        }
        Error(msg) -> ServiceFailure("Failed to save events: " <> msg)
      }
    }
    command_handlers.Failure(error) -> ServiceFailure(error)
  }
}

/// 在庫アイテムを取得
pub fn get_inventory_item(
  service: InventoryService,
  product_id: String,
) -> ServiceResult(Option(aggregate.InventoryItem)) {
  let item = load_inventory_item(service.inventory_store, product_id)
  ServiceSuccess(item)
}

/// 在庫レベルを取得
pub fn get_stock_level(
  service: InventoryService,
  product_id: String,
) -> ServiceResult(Option(aggregate.InventoryItem)) {
  get_inventory_item(service, product_id)
}

/// 在庫アイテムの現在のバージョンを取得
pub fn get_inventory_version(service: InventoryService, product_id: String) -> Int {
  inventory_store.get_version(service.inventory_store, product_id)
}

// 内部ヘルパー関数

/// イベントストアから在庫アイテムを復元
fn load_inventory_item(store: InventoryStore, product_id: String) -> Option(aggregate.InventoryItem) {
  case inventory_store.get_events(store, product_id) {
    Ok(events) -> {
      case events {
        [] -> None
        _ -> {
          case aggregate.from_events(product_id, events) {
            Ok(item) -> Some(item)
            Error(_) -> None  // エラーが発生した場合はNoneを返す
          }
        }
      }
    }
    Error(_) -> None
  }
}

/// コマンドを適切なハンドラーにルーティング
fn route_command(
  current_item: Option(aggregate.InventoryItem),
  command: InventoryCommand,
  current_date: calendar.Date,
) -> command_handlers.CommandResult {
  case command {
    commands.AddProductToInventory(..) ->
      command_handlers.handle_add_product(current_item, command, current_date)
    
    commands.ReceiveStock(..) ->
      command_handlers.handle_receive_stock(current_item, command, current_date)
    
    commands.ReserveStock(..) ->
      command_handlers.handle_reserve_stock(current_item, command, current_date)
    
    commands.ReleaseStockReservation(..) ->
      command_handlers.handle_release_reservation(current_item, command, current_date)
    
    commands.IssueStock(..) ->
      command_handlers.handle_issue_stock(current_item, command, current_date)
    
    commands.AdjustStock(..) ->
      command_handlers.handle_adjust_stock(current_item, command, current_date)
    
    commands.CheckStock(..) ->
      command_handlers.handle_check_stock(current_item, command, current_date)
  }
}