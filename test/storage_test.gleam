import gleam/list
import gleeunit
import gleeunit/should

import app/features/ticket/domain
import app/features/ticket/domain/ticket_status
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

pub fn opaque_key_test() {
  storage.init("sample3")
  let ticket1 =
    domain.Ticket(
      id: domain.ticket_id("1"),
      title: "hoge",
      description: "a",
      status: ticket_status.Done,
      created_at: "2025-01-01",
      replies: [],
    )
  let ticket2 =
    domain.Ticket(
      id: domain.ticket_id("2"),
      title: "hoge",
      description: "a",
      status: ticket_status.Done,
      created_at: "2025-01-01",
      replies: [],
    )
  storage.put("sample3", #(ticket1.id, ticket1))
  storage.put("sample3", #(ticket2.id, ticket2))

  storage.get("sample3", ticket2.id)
  |> should.be_ok()

  storage.delete("sample3", ticket1.id)
  storage.all("sample3")
  |> list.length()
  |> should.equal(1)
}

pub fn delete_key_test() {
  storage.init("sample4")

  storage.put("sample4", #("1", "a"))
  storage.put("sample4", #("2", "b"))

  storage.delete("sample4", "2")

  storage.all("sample4")
  |> list.length()
  |> should.equal(1)
}
