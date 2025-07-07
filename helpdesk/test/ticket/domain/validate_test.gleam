import app/features/ticket/domain
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn validation_success_test() {
  let ticket =
    domain.new_ticket(
      title: "hoge",
      description: "fugafuga",
      created_at: "piyopiyo",
    )

  ticket
  |> should.be_ok()
}

pub fn validation_title_is_empty_test() {
  let ticket =
    domain.new_ticket(
      title: "",
      description: "fugafuga",
      created_at: "piyopiyo",
    )

  ticket
  |> should.equal(Error(["title required"]))
}

pub fn validation_created_at_is_empty_test() {
  let ticket =
    domain.new_ticket(title: "a", description: "fugafuga", created_at: "")

  ticket
  |> should.equal(Error(["created_at required"]))
}

pub fn validation_failure_multi_field_test() {
  let ticket =
    domain.new_ticket(
      title: "",
      description: "fugafuga",
      created_at: "piyopiyo",
    )

  ticket
  |> should.equal(Error(["title required"]))
}
