import order_processing/features/ship_order/domain/core/events.{
  type OrderLine, type ShippingAddress,
}

/// 注文に対するコマンド（意図）
pub type OrderCommand {
  /// 注文を配置する
  PlaceOrder(
    order_id: String,
    customer_name: String,
    customer_email: String,
    shipping_address: ShippingAddress,
    order_lines: List(OrderLine),
  )
  
  /// 注文をバリデートする
  ValidateOrder(order_id: String)
  
  /// 価格を計算する
  CalculatePrice(order_id: String)
  
  /// 決済を処理する
  ProcessPayment(
    order_id: String,
    payment_method: String,
  )
  
  /// 配送準備を行う
  PrepareShipping(order_id: String)
  
  /// 注文を配送する
  ShipOrder(
    order_id: String,
    carrier: String,
  )
  
  /// 注文をキャンセルする
  CancelOrder(
    order_id: String,
    reason: String,
  )
}

/// コマンドから注文IDを取得するヘルパー関数
pub fn get_order_id(command: OrderCommand) -> String {
  case command {
    PlaceOrder(order_id, _, _, _, _) -> order_id
    ValidateOrder(order_id) -> order_id
    CalculatePrice(order_id) -> order_id
    ProcessPayment(order_id, _) -> order_id
    PrepareShipping(order_id) -> order_id
    ShipOrder(order_id, _) -> order_id
    CancelOrder(order_id, _) -> order_id
  }
}