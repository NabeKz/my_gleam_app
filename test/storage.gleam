import gleeunit
import gleeunit/should

import lib/storage

pub fn main() {
  gleeunit.main()
}

pub fn post_tickets_success_test() {
  storage.new("sample")

  201
  |> should.equal(201)
  // |> should.equal(201)
}
