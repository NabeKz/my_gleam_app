/// 在庫に対するコマンド（意図）
pub type InventoryCommand {
  /// 商品を在庫に追加する
  AddProductToInventory(
    product_id: String,
    product_name: String,
    initial_quantity: Int,
  )

  /// 在庫を入庫する
  ReceiveStock(product_id: String, quantity: Int, received_from: String)

  /// 在庫を予約する
  ReserveStock(
    product_id: String,
    quantity: Int,
    reserved_for: String,
    // 注文ID等
  )

  /// 在庫予約を解除する
  ReleaseStockReservation(
    product_id: String,
    quantity: Int,
    reservation_id: String,
  )

  /// 在庫を出庫する
  IssueStock(
    product_id: String,
    quantity: Int,
    issued_to: String,
    // 注文ID等
  )

  /// 在庫を調整する
  AdjustStock(product_id: String, new_quantity: Int, reason: String)

  /// 在庫を確認する
  CheckStock(product_id: String)
}

/// コマンドから商品IDを取得
pub fn get_product_id(command: InventoryCommand) -> String {
  case command {
    AddProductToInventory(product_id, ..) -> product_id
    ReceiveStock(product_id, ..) -> product_id
    ReserveStock(product_id, ..) -> product_id
    ReleaseStockReservation(product_id, ..) -> product_id
    IssueStock(product_id, ..) -> product_id
    AdjustStock(product_id, ..) -> product_id
    CheckStock(product_id) -> product_id
  }
}
