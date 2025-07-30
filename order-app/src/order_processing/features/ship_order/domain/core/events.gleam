import gleam/time/calendar.{type Date}

// 時間はgleam/time/calendarのDate型を使用
/// 注文に関連するイベント（過去に起こった事実）
pub type OrderEvent {
  /// 注文が受け付けられた
  OrderPlaced(
    order_id: String,
    customer_name: String,
    customer_email: String,
    shipping_address: ShippingAddress,
    order_lines: List(OrderLine),
    placed_at: Date,
  )

  /// 注文がバリデートされた（在庫確認・顧客情報確認完了）
  OrderValidated(order_id: String, validated_at: Date)

  /// 価格が計算された
  PriceCalculated(
    order_id: String,
    subtotal: Int,
    tax_amount: Int,
    shipping_cost: Int,
    total_amount: Int,
    calculated_at: Date,
  )

  /// 決済が処理された
  PaymentProcessed(
    order_id: String,
    payment_method: String,
    amount: Int,
    processed_at: Date,
  )

  /// 配送準備が完了した
  ShippingPrepared(
    order_id: String,
    prepared_items: List(String),
    prepared_at: Date,
  )

  /// 配送が開始された
  OrderShipped(
    order_id: String,
    tracking_number: String,
    carrier: String,
    shipped_at: Date,
  )

  /// 注文がキャンセルされた
  OrderCancelled(order_id: String, reason: String, cancelled_at: Date)
}

/// 配送先住所
pub type ShippingAddress {
  ShippingAddress(
    street: String,
    city: String,
    postal_code: String,
    country: String,
  )
}

/// 注文商品行
pub type OrderLine {
  OrderLine(product_name: String, quantity: Int, unit_price: Int)
}
