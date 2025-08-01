import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import gleam/time/calendar
import gleeunit
import gleeunit/should

import order_processing/core/shared/aggregate as shared_aggregate
import order_processing/core/shared/validate
import order_processing/features/inventory/application/inventory_service
import order_processing/features/inventory/domain/core/aggregate
import order_processing/features/inventory/domain/core/events
import order_processing/features/inventory/domain/core/value_objects
import order_processing/features/inventory/domain/logic/command_handlers
import order_processing/features/inventory/domain/logic/commands
import order_processing/features/inventory/infrastructure/inventory_store

pub fn main() {
  gleeunit.main()
}

// テスト用ヘルパー
fn create_test_date() -> calendar.Date {
  let assert Ok(month) = calendar.month_from_int(1)
  calendar.Date(year: 2024, month: month, day: 15)
}

// AddProduct テスト
pub fn add_product_success_test() {
  let command =
    commands.AddProductToInventory(
      product_id: "prod-001",
      product_name: "Test Product",
      initial_quantity: 100,
    )
  let test_date = create_test_date()

  let result = command_handlers.handle_add_product(None, command, test_date)

  case result {
    command_handlers.Success(events) -> {
      should.equal(1, list.length(events))
      case events {
        [event] -> {
          case event {
            events.ProductAddedToInventory(
              product_id: product_id,
              product_name: name,
              initial_quantity: quantity,
              added_at: date,
            ) -> {
              should.equal("prod-001", product_id)
              should.equal("Test Product", name)
              should.equal(100, quantity)
              should.equal(test_date, date)
            }
            _ ->
              should.equal(
                "Expected ProductAddedToInventory",
                "but got different event",
              )
          }
        }
        _ ->
          should.equal(
            "Expected 1 event",
            "but got " <> list.length(events) |> int.to_string,
          )
      }
    }
    command_handlers.Failure(error) ->
      should.equal("Expected success", "but got: " <> error)
  }
}

pub fn add_product_already_exists_test() {
  let command =
    commands.AddProductToInventory(
      product_id: "prod-001",
      product_name: "Test Product",
      initial_quantity: 100,
    )
  let test_date = create_test_date()

  let assert Ok(pid) = value_objects.create_product_id("prod-001")
  let assert Ok(pname) = value_objects.create_product_name("Test Product")
  let existing_item =
    aggregate.InventoryItem(
      product_id: pid,
      product_name: pname,
      available_quantity: 50,
      reserved_quantity: 0,
      total_quantity: 50,
      status: value_objects.Available,
      reservations: [],
      version: 1,
    )

  let result =
    command_handlers.handle_add_product(Some(existing_item), command, test_date)

  case result {
    command_handlers.Failure(error) -> {
      should.equal("Product already exists in inventory", error)
    }
    command_handlers.Success(_) ->
      should.equal("Expected failure", "but got success")
  }
}

// ReceiveStock テスト
pub fn receive_stock_success_test() {
  let command =
    commands.ReceiveStock(
      product_id: "prod-001",
      quantity: 50,
      received_from: "Supplier A",
    )
  let test_date = create_test_date()

  let assert Ok(pid) = value_objects.create_product_id("prod-001")
  let assert Ok(pname) = value_objects.create_product_name("Test Product")
  let existing_item =
    aggregate.InventoryItem(
      product_id: pid,
      product_name: pname,
      available_quantity: 100,
      reserved_quantity: 0,
      total_quantity: 100,
      status: value_objects.Available,
      reservations: [],
      version: 1,
    )

  let result =
    command_handlers.handle_receive_stock(
      Some(existing_item),
      command,
      test_date,
    )

  case result {
    command_handlers.Success(events) -> {
      should.equal(1, list.length(events))
      case events {
        [event] -> {
          case event {
            events.StockReceived(
              product_id: product_id,
              quantity: quantity,
              received_from: from,
              received_at: date,
            ) -> {
              should.equal("prod-001", product_id)
              should.equal(50, quantity)
              should.equal("Supplier A", from)
              should.equal(test_date, date)
            }
            _ ->
              should.equal("Expected StockReceived", "but got different event")
          }
        }
        _ -> should.equal("Expected 1 event", "but got multiple events")
      }
    }
    command_handlers.Failure(error) ->
      should.equal("Expected success", "but got: " <> error)
  }
}

// ReserveStock テスト
pub fn reserve_stock_success_test() {
  let command =
    commands.ReserveStock(
      product_id: "prod-001",
      quantity: 30,
      reserved_for: "order-123",
    )
  let test_date = create_test_date()

  let assert Ok(pid) = value_objects.create_product_id("prod-001")
  let assert Ok(pname) = value_objects.create_product_name("Test Product")
  let existing_item =
    aggregate.InventoryItem(
      product_id: pid,
      product_name: pname,
      available_quantity: 100,
      reserved_quantity: 0,
      total_quantity: 100,
      status: value_objects.Available,
      reservations: [],
      version: 1,
    )

  let result =
    command_handlers.handle_reserve_stock(
      Some(existing_item),
      command,
      test_date,
    )

  case result {
    command_handlers.Success(events) -> {
      should.equal(1, list.length(events))
      case events {
        [event] -> {
          case event {
            events.StockReserved(
              product_id: product_id,
              quantity: quantity,
              reserved_for: reserved_for,
              reserved_at: date,
            ) -> {
              should.equal("prod-001", product_id)
              should.equal(30, quantity)
              should.equal("order-123", reserved_for)
              should.equal(test_date, date)
            }
            _ ->
              should.equal("Expected StockReserved", "but got different event")
          }
        }
        _ -> should.equal("Expected 1 event", "but got multiple events")
      }
    }
    command_handlers.Failure(error) ->
      should.equal("Expected success", "but got: " <> error)
  }
}

pub fn reserve_stock_insufficient_test() {
  let command =
    commands.ReserveStock(
      product_id: "prod-001",
      quantity: 150,
      // 利用可能数量より多い
      reserved_for: "order-123",
    )
  let test_date = create_test_date()

  let assert Ok(pid) = value_objects.create_product_id("prod-001")
  let assert Ok(pname) = value_objects.create_product_name("Test Product")
  let existing_item =
    aggregate.InventoryItem(
      product_id: pid,
      product_name: pname,
      available_quantity: 100,
      reserved_quantity: 0,
      total_quantity: 100,
      status: value_objects.Available,
      reservations: [],
      version: 1,
    )

  let result =
    command_handlers.handle_reserve_stock(
      Some(existing_item),
      command,
      test_date,
    )

  case result {
    command_handlers.Success(events) -> {
      should.equal(1, list.length(events))
      case events {
        [event] -> {
          case event {
            events.StockShortage(
              product_id: product_id,
              requested_quantity: requested,
              available_quantity: available,
              detected_at: date,
            ) -> {
              should.equal("prod-001", product_id)
              should.equal(150, requested)
              should.equal(100, available)
              should.equal(test_date, date)
            }
            _ ->
              should.equal("Expected StockShortage", "but got different event")
          }
        }
        _ -> should.equal("Expected 1 event", "but got multiple events")
      }
    }
    command_handlers.Failure(error) ->
      should.equal("Expected success", "but got: " <> error)
  }
}

// イベント適用テスト
pub fn apply_events_test() {
  let test_date = create_test_date()

  let events = [
    events.ProductAddedToInventory(
      product_id: "prod-001",
      product_name: "Test Product",
      initial_quantity: 100,
      added_at: test_date,
    ),
    events.StockReceived(
      product_id: "prod-001",
      quantity: 50,
      received_from: "Supplier A",
      received_at: test_date,
    ),
    events.StockReserved(
      product_id: "prod-001",
      quantity: 30,
      reserved_for: "order-123",
      reserved_at: test_date,
    ),
  ]

  case aggregate.create_initial_item_from_id("prod-001") {
    Ok(initial_item) -> {
      case
        shared_aggregate.from_events_result(
          initial_item,
          events,
          aggregate.apply_event,
        )
      {
        Ok(item) -> {
          should.equal(
            "prod-001",
            value_objects.product_id_to_string(item.product_id),
          )
          should.equal(
            "Test Product",
            value_objects.product_name_to_string(item.product_name),
          )
          should.equal(120, item.available_quantity)
          // 100 + 50 - 30
          should.equal(30, item.reserved_quantity)
          should.equal(150, item.total_quantity)
          // 100 + 50
          should.equal(value_objects.Available, item.status)
          should.equal(3, item.version)
          should.equal(1, list.length(item.reservations))
        }
        Error(errors) -> {
          let error_messages =
            errors |> list.map(validate.to_string) |> string.join(", ")
          should.equal(
            "Expected success",
            "but got event replay: " <> error_messages,
          )
        }
      }
    }
    Error(errors) -> {
      let error_messages =
        errors |> list.map(validate.to_string) |> string.join(", ")
      should.equal("Expected success", "but got initial: " <> error_messages)
    }
  }
}

// 統合テスト - InventoryService
pub fn inventory_service_integration_test() {
  let store = inventory_store.new()
  let service = inventory_service.new(store)
  let test_date = create_test_date()

  // 1. 商品を追加
  let add_command =
    commands.AddProductToInventory(
      product_id: "prod-001",
      product_name: "Test Product",
      initial_quantity: 100,
    )
  let result1 =
    inventory_service.execute_command(service, add_command, test_date)

  case result1 {
    inventory_service.ServiceSuccess(updated_service) -> {
      // 2. 在庫を入庫
      let receive_command =
        commands.ReceiveStock(
          product_id: "prod-001",
          quantity: 50,
          received_from: "Supplier A",
        )
      let result2 =
        inventory_service.execute_command(
          updated_service,
          receive_command,
          test_date,
        )

      case result2 {
        inventory_service.ServiceSuccess(updated_service2) -> {
          // 3. 在庫アイテムを取得して状態を確認
          let get_result =
            inventory_service.get_inventory_item(updated_service2, "prod-001")

          case get_result {
            inventory_service.ServiceSuccess(maybe_item) -> {
              case maybe_item {
                Some(item) -> {
                  should.equal(150, item.available_quantity)
                  // 100 + 50
                  should.equal(0, item.reserved_quantity)
                  should.equal(150, item.total_quantity)
                  should.equal(value_objects.Available, item.status)
                  should.equal(2, item.version)
                  // 2つのイベントが適用されている
                }
                None -> should.equal("Expected item", "but got None")
              }
            }
            inventory_service.ServiceFailure(error) ->
              should.equal("Expected success", "but got: " <> error)
          }
        }
        inventory_service.ServiceFailure(error) ->
          should.equal("Expected success", "but got: " <> error)
      }
    }
    inventory_service.ServiceFailure(error) ->
      should.equal("Expected success", "but got: " <> error)
  }
}
