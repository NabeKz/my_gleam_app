import gleam/string

/// 商品ID（不正な状態を型で排除）
pub opaque type ProductId {
  ProductId(String)
}

/// 商品IDを作成（バリデーション付き）
pub fn create_product_id(id: String) -> Result(ProductId, String) {
  case string.length(id) > 0 && string.length(id) <= 50 {
    True -> Ok(ProductId(id))
    False -> Error("Product ID must be between 1 and 50 characters")
  }
}

/// 商品IDの値を取得
pub fn product_id_to_string(product_id: ProductId) -> String {
  let ProductId(value) = product_id
  value
}

/// 商品名（不正な状態を型で排除）
pub opaque type ProductName {
  ProductName(String)
}

/// 商品名を作成（バリデーション付き）
pub fn create_product_name(name: String) -> Result(ProductName, String) {
  case string.length(name) > 0 && string.length(name) <= 100 {
    True -> Ok(ProductName(name))
    False -> Error("Product name must be between 1 and 100 characters")
  }
}

/// 商品名の値を取得
pub fn product_name_to_string(product_name: ProductName) -> String {
  let ProductName(value) = product_name
  value
}

/// 在庫数量（負の値を排除）
pub opaque type StockQuantity {
  StockQuantity(Int)
}

/// 在庫数量を作成（バリデーション付き）
pub fn create_stock_quantity(quantity: Int) -> Result(StockQuantity, String) {
  case quantity >= 0 {
    True -> Ok(StockQuantity(quantity))
    False -> Error("Stock quantity cannot be negative")
  }
}

/// 在庫数量の値を取得
pub fn stock_quantity_to_int(quantity: StockQuantity) -> Int {
  let StockQuantity(value) = quantity
  value
}

/// 在庫状態
pub type StockStatus {
  Available      // 利用可能
  Reserved       // 予約済み
  OutOfStock     // 在庫切れ
  Discontinued   // 廃止予定
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
) -> Result(StockLevel, String) {
  case
    create_stock_quantity(available),
    create_stock_quantity(reserved),
    create_stock_quantity(available + reserved)
  {
    Ok(avail), Ok(res), Ok(tot) -> Ok(StockLevel(avail, res, tot))
    Error(err), _, _ -> Error(err)
    _, Error(err), _ -> Error(err)
    _, _, Error(err) -> Error(err)
  }
}

/// 商品情報
pub type ProductInfo {
  ProductInfo(
    product_id: ProductId,
    product_name: ProductName,
    status: StockStatus,
  )
}