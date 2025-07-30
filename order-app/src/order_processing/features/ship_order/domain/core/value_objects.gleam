import gleam/string

/// メールアドレス（不正な状態を型で排除）
pub opaque type EmailAddress {
  EmailAddress(String)
}

/// メールアドレスを作成（バリデーション付き）
pub fn create_email(email: String) -> Result(EmailAddress, String) {
  case string.contains(email, "@") && string.length(email) > 3 {
    True -> Ok(EmailAddress(email))
    False -> Error("Invalid email format")
  }
}

/// メールアドレスの値を取得
pub fn email_to_string(email: EmailAddress) -> String {
  let EmailAddress(value) = email
  value
}

/// 価格（負の値を排除）
pub opaque type Price {
  Price(Int)
}

/// 価格を作成（バリデーション付き）
pub fn create_price(amount: Int) -> Result(Price, String) {
  case amount >= 0 {
    True -> Ok(Price(amount))
    False -> Error("Price cannot be negative")
  }
}

/// 価格の値を取得
pub fn price_to_int(price: Price) -> Int {
  let Price(value) = price
  value
}

/// 数量（0以下を排除）
pub opaque type Quantity {
  Quantity(Int)
}

/// 数量を作成（バリデーション付き）
pub fn create_quantity(qty: Int) -> Result(Quantity, String) {
  case qty > 0 {
    True -> Ok(Quantity(qty))
    False -> Error("Quantity must be positive")
  }
}

/// 数量の値を取得
pub fn quantity_to_int(qty: Quantity) -> Int {
  let Quantity(value) = qty
  value
}

/// 商品名（空文字列を排除）
pub opaque type ProductName {
  ProductName(String)
}

/// 商品名を作成（バリデーション付き）
pub fn create_product_name(name: String) -> Result(ProductName, String) {
  let trimmed = string.trim(name)
  case string.length(trimmed) > 0 {
    True -> Ok(ProductName(trimmed))
    False -> Error("Product name cannot be empty")
  }
}

/// 商品名の値を取得
pub fn product_name_to_string(name: ProductName) -> String {
  let ProductName(value) = name
  value
}

/// 顧客情報
pub type CustomerInfo {
  CustomerInfo(name: String, email: EmailAddress)
}

/// 注文状況
pub type OrderStatus {
  /// 注文受付済み
  Placed
  /// バリデーション済み
  Validated
  /// 価格計算済み
  PriceCalculated
  /// 決済処理済み
  PaymentProcessed
  /// 配送準備済み
  ShippingPrepared
  /// 配送済み
  Shipped
  /// キャンセル済み
  Cancelled
}

/// 注文状況を文字列に変換
pub fn order_status_to_string(status: OrderStatus) -> String {
  case status {
    Placed -> "Placed"
    Validated -> "Validated"
    PriceCalculated -> "PriceCalculated"
    PaymentProcessed -> "PaymentProcessed"
    ShippingPrepared -> "ShippingPrepared"
    Shipped -> "Shipped"
    Cancelled -> "Cancelled"
  }
}
