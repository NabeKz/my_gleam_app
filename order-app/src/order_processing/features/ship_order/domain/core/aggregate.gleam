import gleam/list
import gleam/option.{type Option, None, Some}

import order_processing/features/ship_order/domain/core/events.{
  type OrderEvent, type OrderLine, type ShippingAddress,
}
import order_processing/features/ship_order/domain/core/value_objects.{
  type CustomerInfo, type OrderStatus, Cancelled, PaymentProcessed, Placed,
  PriceCalculated, Shipped, ShippingPrepared, Validated,
}

/// 注文アグリゲート
pub type Order {
  Order(
    id: String,
    status: OrderStatus,
    customer_info: Option(CustomerInfo),
    shipping_address: Option(ShippingAddress),
    order_lines: List(OrderLine),
    subtotal: Option(Int),
    tax_amount: Option(Int),
    shipping_cost: Option(Int),
    total_amount: Option(Int),
    tracking_number: Option(String),
    version: Int,
  )
}

/// 新しい空の注文を作成
pub fn new_order(id: String) -> Order {
  Order(
    id: id,
    status: Placed,
    customer_info: None,
    shipping_address: None,
    order_lines: [],
    subtotal: None,
    tax_amount: None,
    shipping_cost: None,
    total_amount: None,
    tracking_number: None,
    version: 0,
  )
}

/// 1つのイベントから状態を更新
pub fn apply_event(order: Order, event: OrderEvent) -> Order {
  case event {
    events.OrderPlaced(
      order_id,
      customer_name,
      customer_email,
      shipping_address,
      order_lines,
      _placed_at,
    ) -> {
      // EmailAddressの作成は既にバリデーション済みと仮定
      case value_objects.create_email(customer_email) {
        Ok(email) -> {
          let customer_info =
            value_objects.CustomerInfo(name: customer_name, email: email)
          Order(
            ..order,
            id: order_id,
            status: Placed,
            customer_info: Some(customer_info),
            shipping_address: Some(shipping_address),
            order_lines: order_lines,
            version: order.version + 1,
          )
        }
        Error(_) -> order
        // バリデーションエラーの場合は状態を変更しない
      }
    }

    events.OrderValidated(_order_id, _validated_at) ->
      Order(..order, status: Validated, version: order.version + 1)

    events.PriceCalculated(
      _order_id,
      subtotal,
      tax_amount,
      shipping_cost,
      total_amount,
      _calculated_at,
    ) ->
      Order(
        ..order,
        status: PriceCalculated,
        subtotal: Some(subtotal),
        tax_amount: Some(tax_amount),
        shipping_cost: Some(shipping_cost),
        total_amount: Some(total_amount),
        version: order.version + 1,
      )

    events.PaymentProcessed(_order_id, _payment_method, _amount, _processed_at) ->
      Order(..order, status: PaymentProcessed, version: order.version + 1)

    events.ShippingPrepared(_order_id, _prepared_items, _prepared_at) ->
      Order(..order, status: ShippingPrepared, version: order.version + 1)

    events.OrderShipped(_order_id, tracking_number, _carrier, _shipped_at) ->
      Order(
        ..order,
        status: Shipped,
        tracking_number: Some(tracking_number),
        version: order.version + 1,
      )

    events.OrderCancelled(_order_id, _reason, _cancelled_at) ->
      Order(..order, status: Cancelled, version: order.version + 1)
  }
}

/// イベントリストから状態を再構築
pub fn apply_events(order: Order, events: List(OrderEvent)) -> Order {
  list.fold(events, order, apply_event)
}

/// イベントリストから注文を復元
pub fn from_events(order_id: String, events: List(OrderEvent)) -> Order {
  let initial_order = new_order(order_id)
  apply_events(initial_order, events)
}

/// 注文が特定の状態にあるかチェック
pub fn is_in_status(order: Order, status: OrderStatus) -> Bool {
  order.status == status
}

/// 注文がキャンセル可能かチェック
pub fn can_be_cancelled(order: Order) -> Bool {
  case order.status {
    Placed | Validated | PriceCalculated -> True
    PaymentProcessed | ShippingPrepared | Shipped | Cancelled -> False
  }
}
