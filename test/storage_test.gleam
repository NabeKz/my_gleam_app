import gleam/list
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
  |> should.equal(#("a", "b") |> Ok())

  storage.put("sample", #("a", "c"))
  storage.get("sample", "a")
  |> should.equal(#("a", "c") |> Ok())

  storage.delete("sample", "a")
  storage.get("sample", "a")
  |> should.equal(Error("not found"))
}

pub fn repository_select_success_test() {
  storage.init("sample2")
  storage.put("sample2", #("a", "b"))
  storage.put("sample2", #("c", "d"))
  storage.all("sample2")
  |> list.length()
  |> should.equal(2)
}
