import gleam/time/calendar.{type Date}

/// 在庫に関連するイベント（過去に起こった事実）
pub type InventoryEvent {
  /// 商品が在庫に追加された
  ProductAddedToInventory(
    product_id: String,
    product_name: String,
    initial_quantity: Int,
    added_at: Date,
  )

  /// 在庫が入庫された
  StockReceived(
    product_id: String,
    quantity: Int,
    received_from: String,
    received_at: Date,
  )

  /// 在庫が予約された
  StockReserved(
    product_id: String,
    quantity: Int,
    reserved_for: String,
    // 注文ID等
    reserved_at: Date,
  )

  /// 在庫予約が解除された
  StockReservationReleased(
    product_id: String,
    quantity: Int,
    reservation_id: String,
    released_at: Date,
  )

  /// 在庫が出庫された
  StockIssued(
    product_id: String,
    quantity: Int,
    issued_to: String,
    // 注文ID等
    issued_at: Date,
  )

  /// 在庫調整が行われた
  StockAdjusted(
    product_id: String,
    old_quantity: Int,
    new_quantity: Int,
    reason: String,
    adjusted_at: Date,
  )

  /// 在庫が不足している
  StockShortage(
    product_id: String,
    requested_quantity: Int,
    available_quantity: Int,
    detected_at: Date,
  )
}

/// 在庫予約情報
pub type StockReservation {
  StockReservation(
    reservation_id: String,
    product_id: String,
    quantity: Int,
    reserved_for: String,
    reserved_at: Date,
  )
}

/// 在庫トランザクション情報
pub type StockTransaction {
  StockTransaction(
    transaction_id: String,
    product_id: String,
    transaction_type: TransactionType,
    quantity: Int,
    reference: String,
    timestamp: Date,
  )
}

/// トランザクション種別
pub type TransactionType {
  Receipt
  // 入庫
  Issue
  // 出庫
  Reserve
  // 予約
  Release
  // 予約解除
  Adjust
  // 調整
}
