import gleeunit
import gleeunit/should

import lib/storage

pub fn main() {
  gleeunit.main()
}

pub fn storage_success_test() {
  storage.init("sample")
  storage.put("sample", #("a", "b"))
  storage.put("sample", #("c", "d"))

  storage.get("sample", "a")
  |> should.equal([#("a", "b")])

  storage.put("sample", #("a", "c"))
  storage.get("sample", "a")
  |> should.equal([#("a", "c")])

  storage.delete("sample", "a")
  storage.get("sample", "a")
  |> should.equal([])
}
