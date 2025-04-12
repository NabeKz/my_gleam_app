import app/ticket/domain.{type Ticket}
import lib/date_time

pub fn invoke() -> List(Ticket) {
  let d = date_time.now() |> date_time.to_string
  [
    domain.new_ticket("1", "hogehoge", d),
    domain.new_ticket("2", "fugafuga", d),
    domain.new_ticket("3", "piyopiyo", d),
    domain.new_ticket("4", "foobar", d),
  ]
}
