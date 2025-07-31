import gleeunit
import gleeunit/should

import order_processing/core/shared/validate

pub fn main() {
  gleeunit.main()
}

// 文字列バリデーションテスト
pub fn string_validation_success_test() {
  let rules = [validate.non_empty, validate.range(_, 3, 20)]

  let result = validate.field("product_id", "hoge", rules) |> validate.run()

  result
  |> should.equal(Ok("hoge"))
}
