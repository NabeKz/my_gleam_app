import gleam/result
import gleam/string

import order_processing/core/shared/validate

/// 商品ID（不正な状態を型で排除）
pub opaque type ProductId {
  ProductId(String)
}

/// 商品IDを作成（バリデーション付き）
pub fn create_product_id(
  id: String,
) -> Result(ProductId, List(validate.ValidateError)) {
  validate.field("Product ID", id, [
    validate.non_empty,
    validate.range(_, 1, 50),
  ])
  |> validate.run()
  |> validate.success(ProductId)
}

/// 商品IDの値を取得
pub fn product_id_to_string(product_id: ProductId) -> String {
  let ProductId(value) = product_id
  value
}

/// 検証済みの値から商品IDを作成（バリデーションをスキップ）
/// 注意: この関数は aggregate の apply_event でのみ使用すること
pub fn unsafe_create_product_id(id: String) -> ProductId {
  ProductId(id)
}

/// 商品名（不正な状態を型で排除）
pub opaque type ProductName {
  ProductName(String)
}

/// 商品名を作成（バリデーション付き）
pub fn create_product_name(
  name: String,
) -> Result(ProductName, List(validate.ValidateError)) {
  validate.field("Product name", name, [
    validate.non_empty,
    validate.range(_, 1, 100),
  ])
  |> validate.run()
  |> validate.success(ProductName)
}

/// 商品名の値を取得
pub fn product_name_to_string(product_name: ProductName) -> String {
  let ProductName(value) = product_name
  value
}

/// 検証済みの値から商品名を作成（バリデーションをスキップ）
/// 注意: この関数は aggregate の apply_event でのみ使用すること
pub fn unsafe_create_product_name(name: String) -> ProductName {
  ProductName(name)
}

/// 在庫数量（負の値を排除）
pub opaque type StockQuantity {
  StockQuantity(Int)
}

/// 在庫数量を作成（バリデーション付き）
pub fn create_stock_quantity(
  quantity: Int,
) -> Result(StockQuantity, List(validate.ValidateError)) {
  validate.field("Stock quantity", quantity, [validate.min(_, 0)])
  |> validate.run()
  |> validate.success(StockQuantity)
}

/// 在庫数量の値を取得
pub fn stock_quantity_to_int(quantity: StockQuantity) -> Int {
  let StockQuantity(value) = quantity
  value
}

/// 検証済みの値から在庫数量を作成（バリデーションをスキップ）  
/// 注意: この関数は aggregate の apply_event でのみ使用すること
pub fn unsafe_create_stock_quantity(quantity: Int) -> StockQuantity {
  StockQuantity(quantity)
}

/// 在庫状態
pub type StockStatus {
  Available
  // 利用可能
  Reserved
  // 予約済み
  OutOfStock
  // 在庫切れ
  Discontinued
  // 廃止予定
}

/// 在庫状態を文字列に変換
pub fn stock_status_to_string(status: StockStatus) -> String {
  case status {
    Available -> "Available"
    Reserved -> "Reserved"
    OutOfStock -> "OutOfStock"
    Discontinued -> "Discontinued"
  }
}

/// 予約ID（不正な状態を型で排除）
pub opaque type ReservationId {
  ReservationId(String)
}

/// 予約IDを作成（バリデーション付き）
pub fn create_reservation_id(id: String) -> Result(ReservationId, String) {
  case string.length(id) > 0 && string.length(id) <= 50 {
    True -> Ok(ReservationId(id))
    False -> Error("Reservation ID must be between 1 and 50 characters")
  }
}

/// 予約IDの値を取得
pub fn reservation_id_to_string(reservation_id: ReservationId) -> String {
  let ReservationId(value) = reservation_id
  value
}

/// 在庫レベル情報
pub type StockLevel {
  StockLevel(
    available: StockQuantity,
    reserved: StockQuantity,
    total: StockQuantity,
  )
}

/// 在庫レベルを作成
pub fn create_stock_level(
  available: Int,
  reserved: Int,
) -> Result(StockLevel, List(validate.ValidateError)) {
  use available_qty <- result.try(create_stock_quantity(available))
  use reserved_qty <- result.try(create_stock_quantity(reserved))  
  use total_qty <- result.try(create_stock_quantity(available + reserved))
  Ok(StockLevel(available_qty, reserved_qty, total_qty))
}

/// 商品情報
pub type ProductInfo {
  ProductInfo(
    product_id: ProductId,
    product_name: ProductName,
    status: StockStatus,
  )
}
