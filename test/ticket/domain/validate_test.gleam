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

pub fn validation_failure_test() {
  let ticket =
    domain.new_ticket(
      id: "1",
      title: "",
      description: "fugafuga",
      created_at: "piyopiyo",
    )

  ticket
  |> should.be_error()
}
