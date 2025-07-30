import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/time/calendar
import gleeunit
import gleeunit/should

import order_processing/features/ship_order/application/order_service
import order_processing/features/ship_order/domain/core/aggregate
import order_processing/features/ship_order/domain/core/events
import order_processing/features/ship_order/domain/core/value_objects
import order_processing/features/ship_order/domain/logic/command_handlers
import order_processing/features/ship_order/domain/logic/commands
import order_processing/features/ship_order/infrastructure/event_store

pub fn main() {
  gleeunit.main()
}

// テスト用ヘルパー
fn create_test_date() -> calendar.Date {
  let assert Ok(month) = calendar.month_from_int(1)
  calendar.Date(year: 2024, month: month, day: 15)
}

fn create_valid_place_order_command() -> commands.OrderCommand {
  commands.PlaceOrder(
    order_id: "order-001",
    customer_name: "Test Customer",
    customer_email: "test@example.com",
    shipping_address: events.ShippingAddress(
      street: "123 Test St",
      city: "Test City",
      postal_code: "12345",
      country: "Test Country",
    ),
    order_lines: [
      events.OrderLine(
        product_name: "Test Product",
        quantity: 2,
        unit_price: 1000,
      ),
    ],
  )
}

// PlaceOrder テスト
pub fn place_order_success_test() {
  let command = create_valid_place_order_command()
  let test_date = create_test_date()

  let result = command_handlers.handle_place_order(None, command, test_date)

  case result {
    command_handlers.Success(events) -> {
      should.equal(1, list.length(events))
      case events {
        [event] -> {
          case event {
            events.OrderPlaced(
              order_id: order_id,
              customer_name: name,
              placed_at: date,
              ..,
            ) -> {
              should.equal("order-001", order_id)
              should.equal("Test Customer", name)
              should.equal(test_date, date)
            }
            _ -> should.equal("Expected OrderPlaced", "but got different event")
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

pub fn place_order_already_exists_test() {
  let command = create_valid_place_order_command()
  let test_date = create_test_date()

  let existing_order =
    aggregate.Order(
      id: "order-001",
      status: value_objects.Placed,
      customer_info: None,
      shipping_address: None,
      order_lines: [],
      subtotal: None,
      tax_amount: None,
      shipping_cost: None,
      total_amount: None,
      tracking_number: None,
      version: 1,
    )

  let result =
    command_handlers.handle_place_order(
      Some(existing_order),
      command,
      test_date,
    )

  case result {
    command_handlers.Failure(error) -> {
      should.equal("Order already exists", error)
    }
    command_handlers.Success(_) ->
      should.equal("Expected failure", "but got success")
  }
}

// バリデーションテスト
pub fn place_order_invalid_email_test() {
  let assert Error(_) = value_objects.create_email("invalid-email")
  // 無効なメールアドレスは作成時点で失敗することを確認
  should.equal(True, True)
}

pub fn place_order_invalid_quantity_test() {
  let result = value_objects.create_quantity(-1)
  case result {
    Error(_) -> should.equal(True, True)
    // 負の数量は拒否される
    Ok(_) -> should.equal("Expected error", "but got success")
  }
}

// ValidateOrder テスト
pub fn validate_order_success_test() {
  let command = commands.ValidateOrder("order-001")
  let test_date = create_test_date()

  let order =
    aggregate.Order(
      id: "order-001",
      status: value_objects.Placed,
      customer_info: None,
      shipping_address: None,
      order_lines: [],
      subtotal: None,
      tax_amount: None,
      shipping_cost: None,
      total_amount: None,
      tracking_number: None,
      version: 1,
    )

  let result =
    command_handlers.handle_validate_order(Some(order), command, test_date)

  case result {
    command_handlers.Success(events) -> {
      should.equal(1, list.length(events))
      case events {
        [event] -> {
          case event {
            events.OrderValidated(order_id: order_id, validated_at: date) -> {
              should.equal("order-001", order_id)
              should.equal(test_date, date)
            }
            _ ->
              should.equal("Expected OrderValidated", "but got different event")
          }
        }
        _ -> should.equal("Expected 1 event", "but got multiple events")
      }
    }
    command_handlers.Failure(error) ->
      should.equal("Expected success", "but got: " <> error)
  }
}

pub fn validate_order_wrong_status_test() {
  let command = commands.ValidateOrder("order-001")
  let test_date = create_test_date()

  // 既にValidated状態の注文
  let order =
    aggregate.Order(
      id: "order-001",
      status: value_objects.Validated,
      customer_info: None,
      shipping_address: None,
      order_lines: [],
      subtotal: None,
      tax_amount: None,
      shipping_cost: None,
      total_amount: None,
      tracking_number: None,
      version: 1,
    )

  let result =
    command_handlers.handle_validate_order(Some(order), command, test_date)

  case result {
    command_handlers.Failure(error) -> {
      should.not_equal("", error)
      // エラーメッセージがあることを確認
    }
    command_handlers.Success(_) ->
      should.equal("Expected failure", "but got success")
  }
}

// CalculatePrice テスト
pub fn calculate_price_success_test() {
  let command = commands.CalculatePrice("order-001")
  let test_date = create_test_date()

  let order =
    aggregate.Order(
      id: "order-001",
      status: value_objects.Validated,
      customer_info: None,
      shipping_address: None,
      order_lines: [
        events.OrderLine(
          product_name: "Test Product",
          quantity: 2,
          unit_price: 1000,
        ),
      ],
      subtotal: None,
      tax_amount: None,
      shipping_cost: None,
      total_amount: None,
      tracking_number: None,
      version: 1,
    )

  let result =
    command_handlers.handle_calculate_price(Some(order), command, test_date)

  case result {
    command_handlers.Success(events) -> {
      should.equal(1, list.length(events))
      case events {
        [event] -> {
          case event {
            events.PriceCalculated(
              order_id: order_id,
              subtotal: subtotal,
              total_amount: total,
              calculated_at: date,
              ..,
            ) -> {
              should.equal("order-001", order_id)
              should.equal(2000, subtotal)
              // 1000 * 2
              should.equal(test_date, date)
              should.not_equal(0, total)
              // 総額は0ではない
            }
            _ ->
              should.equal(
                "Expected PriceCalculated",
                "but got different event",
              )
          }
        }
        _ -> should.equal("Expected 1 event", "but got multiple events")
      }
    }
    command_handlers.Failure(error) ->
      should.equal("Expected success", "but got: " <> error)
  }
}

// Event Store + Application Service の統合テスト
pub fn full_workflow_integration_test() {
  let store = event_store.new()
  let service = order_service.new(store)
  let test_date = create_test_date()

  // 1. 注文を配置
  let place_command = create_valid_place_order_command()
  let result1 = order_service.execute_command(service, place_command, test_date)

  case result1 {
    order_service.ServiceSuccess(updated_service) -> {
      // 2. 注文をバリデーション
      let validate_command = commands.ValidateOrder("order-001")
      let result2 =
        order_service.execute_command(
          updated_service,
          validate_command,
          test_date,
        )

      case result2 {
        order_service.ServiceSuccess(updated_service2) -> {
          // 3. 注文を取得して状態を確認
          let get_result =
            order_service.get_order(updated_service2, "order-001")

          case get_result {
            order_service.ServiceSuccess(maybe_order) -> {
              case maybe_order {
                Some(order) -> {
                  should.equal(value_objects.Validated, order.status)
                  should.equal(2, order.version)
                  // 2つのイベントが適用されている
                }
                None -> should.equal("Expected order", "but got None")
              }
            }
            order_service.ServiceFailure(error) ->
              should.equal("Expected success", "but got: " <> error)
          }
        }
        order_service.ServiceFailure(error) ->
          should.equal("Expected success", "but got: " <> error)
      }
    }
    order_service.ServiceFailure(error) ->
      should.equal("Expected success", "but got: " <> error)
  }
}
