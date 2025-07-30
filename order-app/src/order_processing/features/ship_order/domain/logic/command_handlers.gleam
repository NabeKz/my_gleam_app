import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/time/calendar
import gleam/time/timestamp

// 時間処理（現在は文字列、後でgleam/time/calendarに変更予定）
import gleam/int
import order_processing/features/ship_order/domain/core/aggregate
import order_processing/features/ship_order/domain/core/events
import order_processing/features/ship_order/domain/core/value_objects
import order_processing/features/ship_order/domain/logic/commands.{
  type OrderCommand, CalculatePrice, CancelOrder, PlaceOrder, PrepareShipping,
  ProcessPayment, ShipOrder, ValidateOrder,
}

/// コマンド処理結果
pub type CommandResult {
  Success(events: List(events.OrderEvent))
  Failure(error: String)
}

/// Railway Oriented Programming - 複数のバリデーション結果を結合
pub fn combine_validations(
  results: List(Result(Nil, String)),
) -> Result(Nil, String) {
  let errors =
    results
    |> list.filter_map(fn(r) {
      case r {
        Ok(_) -> Error(Nil)
        Error(msg) -> Ok(msg)
      }
    })

  case errors {
    [] -> Ok(Nil)
    [first, ..rest] -> Error(string.join([first, ..rest], ", "))
  }
}

/// 注文配置コマンドを処理
pub fn handle_place_order(
  current_order: Option(aggregate.Order),
  command: commands.OrderCommand,
) -> CommandResult {
  // 既に注文が存在する場合はエラー
  case current_order {
    Some(_) -> Failure("Order already exists")
    None -> {
      let assert commands.PlaceOrder(
        order_id,
        customer_name,
        customer_email,
        shipping_address,
        order_lines,
      ) = command

      // バリデーション実行
      let validations = [
        validate_customer_name(customer_name),
        validate_customer_email(customer_email),
        validate_shipping_address(shipping_address),
        validate_order_lines(order_lines),
      ]

      case combine_validations(validations) {
        Ok(_) -> {
          // 現在時刻を取得（実際の実装では依存性注入が望ましい）
          let now = get_current_time()
          let event =
            events.OrderPlaced(
              order_id: order_id,
              customer_name: customer_name,
              customer_email: customer_email,
              shipping_address: shipping_address,
              order_lines: order_lines,
              placed_at: now,
            )
          Success([event])
        }
        Error(msg) -> Failure(msg)
      }
    }
  }
}

/// 注文バリデーションコマンドを処理
pub fn handle_validate_order(
  current_order: Option(aggregate.Order),
  command: commands.OrderCommand,
) -> CommandResult {
  case current_order {
    None -> Failure("Order not found")
    Some(order) -> {
      case aggregate.is_in_status(order, value_objects.Placed) {
        True -> {
          let assert commands.ValidateOrder(order_id) = command
          let now = get_current_time()
          let event =
            events.OrderValidated(order_id: order_id, validated_at: now)
          Success([event])
        }
        False ->
          Failure(
            "Order cannot be validated in current status: "
            <> value_objects.order_status_to_string(order.status),
          )
      }
    }
  }
}

/// 価格計算コマンドを処理
pub fn handle_calculate_price(
  current_order: Option(aggregate.Order),
  command: commands.OrderCommand,
) -> CommandResult {
  case current_order {
    None -> Failure("Order not found")
    Some(order) -> {
      case aggregate.is_in_status(order, value_objects.Validated) {
        True -> {
          let assert commands.CalculatePrice(order_id) = command

          // 価格計算ロジック
          let subtotal = calculate_subtotal(order.order_lines)
          let tax_amount = calculate_tax(subtotal)
          let shipping_cost = calculate_shipping_cost(order.order_lines)
          let total_amount = subtotal + tax_amount + shipping_cost

          let now = get_current_time()
          let event =
            events.PriceCalculated(
              order_id: order_id,
              subtotal: subtotal,
              tax_amount: tax_amount,
              shipping_cost: shipping_cost,
              total_amount: total_amount,
              calculated_at: now,
            )
          Success([event])
        }
        False ->
          Failure(
            "Price calculation not allowed in current status: "
            <> value_objects.order_status_to_string(order.status),
          )
      }
    }
  }
}

/// 注文キャンセルコマンドを処理
pub fn handle_cancel_order(
  current_order: Option(aggregate.Order),
  command: commands.OrderCommand,
) -> CommandResult {
  case current_order {
    None -> Failure("Order not found")
    Some(order) -> {
      case aggregate.can_be_cancelled(order) {
        True -> {
          let assert commands.CancelOrder(order_id, reason) = command
          let now = get_current_time()
          let event =
            events.OrderCancelled(
              order_id: order_id,
              reason: reason,
              cancelled_at: now,
            )
          Success([event])
        }
        False ->
          Failure(
            "Order cannot be cancelled in current status: "
            <> value_objects.order_status_to_string(order.status),
          )
      }
    }
  }
}

// バリデーション関数群

/// 顧客名のバリデーション
fn validate_customer_name(name: String) -> Result(Nil, String) {
  let trimmed = string.trim(name)
  case string.length(trimmed) > 0 {
    True -> Ok(Nil)
    False -> Error("Customer name cannot be empty")
  }
}

/// 顧客メールアドレスのバリデーション
fn validate_customer_email(email: String) -> Result(Nil, String) {
  case value_objects.create_email(email) {
    Ok(_) -> Ok(Nil)
    Error(msg) -> Error(msg)
  }
}

/// 配送先住所のバリデーション
fn validate_shipping_address(
  address: events.ShippingAddress,
) -> Result(Nil, String) {
  let events.ShippingAddress(street, city, postal_code, country) = address
  let validations = [
    case string.trim(street) |> string.length() > 0 {
      True -> Ok(Nil)
      False -> Error("Street address cannot be empty")
    },
    case string.trim(city) |> string.length() > 0 {
      True -> Ok(Nil)
      False -> Error("City cannot be empty")
    },
    case string.trim(postal_code) |> string.length() > 0 {
      True -> Ok(Nil)
      False -> Error("Postal code cannot be empty")
    },
    case string.trim(country) |> string.length() > 0 {
      True -> Ok(Nil)
      False -> Error("Country cannot be empty")
    },
  ]
  combine_validations(validations)
}

/// 注文商品リストのバリデーション
fn validate_order_lines(
  order_lines: List(events.OrderLine),
) -> Result(Nil, String) {
  case order_lines {
    [] -> Error("Order must contain at least one item")
    lines -> {
      lines
      |> list.map(validate_order_line)
      |> combine_validations()
    }
  }
}

/// 個別の注文商品のバリデーション
fn validate_order_line(line: events.OrderLine) -> Result(Nil, String) {
  let events.OrderLine(product_name, quantity, unit_price) = line
  let validations = [
    case value_objects.create_product_name(product_name) {
      Ok(_) -> Ok(Nil)
      Error(msg) -> Error(msg)
    },
    case value_objects.create_quantity(quantity) {
      Ok(_) -> Ok(Nil)
      Error(msg) -> Error(msg)
    },
    case value_objects.create_price(unit_price) {
      Ok(_) -> Ok(Nil)
      Error(msg) -> Error(msg)
    },
  ]
  combine_validations(validations)
}

// 価格計算関数群

/// 小計の計算
fn calculate_subtotal(order_lines: List(events.OrderLine)) -> Int {
  order_lines
  |> list.map(fn(line) {
    let events.OrderLine(_, quantity, unit_price) = line
    quantity * unit_price
  })
  |> list.fold(0, int.add)
}

/// 税額の計算（10%の消費税）
fn calculate_tax(subtotal: Int) -> Int {
  subtotal * 10 / 100
}

/// 配送料の計算（簡単な例：商品数に基づく）
fn calculate_shipping_cost(order_lines: List(events.OrderLine)) -> Int {
  let total_items =
    order_lines
    |> list.map(fn(line) { line.quantity })
    |> list.fold(0, int.add)

  // 5個まで500円、それ以降は1個につき100円追加
  case total_items <= 5 {
    True -> 500
    False -> 500 + { total_items - 5 } * 100
  }
}

/// 現在時刻を取得
fn get_current_time() -> calendar.Date {
  // 現在のタイムスタンプを取得してDate型に変換
  let now_timestamp = timestamp.system_time()
  let #(date, _time) = timestamp.to_calendar(now_timestamp, calendar.utc_offset)
  date
}
