import app/features/ticket/domain
import gleam/option
import gleeunit
import gleeunit/should

import app/features/ticket/infra/ticket_repository_on_ets as ets
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
  domain.ValidateSearchParams(
    title: option.None,
    status: option.None,
    created_at: option.None,
  )
  |> ets.new().list()
  |> should.equal([])
}
