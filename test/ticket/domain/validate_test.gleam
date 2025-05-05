import app/ticket/domain
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn validation_success_test() {
  let ticket =
    domain.new_ticket(
      id: "1",
      title: "hoge",
      description: "fugafuga",
      created_at: "piyopiyo",
    )

  ticket
  |> should.be_ok()
}

pub fn validation_id_is_empty_test() {
  let ticket =
    domain.new_ticket(
      id: "",
      title: "a",
      description: "fugafuga",
      created_at: "piyopiyo",
    )

  ticket
  |> should.equal(Error(["id required"]))
}

pub fn validation_title_is_empty_test() {
  let ticket =
    domain.new_ticket(
      id: "1",
      title: "",
      description: "fugafuga",
      created_at: "piyopiyo",
    )

  ticket
  |> should.equal(Error(["title required"]))
}

pub fn validation_failure_multi_field_test() {
  let ticket =
    domain.new_ticket(
      id: "",
      title: "",
      description: "fugafuga",
      created_at: "piyopiyo",
    )

  ticket
  |> should.equal(Error(["id required", "title required"]))
}
