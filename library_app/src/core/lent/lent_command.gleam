import core/lent/events

pub type LentBookCommand {
  LentBookCommand(book_id: String, renter_id: String)
}

pub type ReturnBookCommand {
  ReturnBookCommand(book_id: String, renter_id: String)
}

pub type GetEventsByBook =
  fn(String) -> List(events.LentEvent)

pub type AppendEvent =
  fn(events.LentEvent) -> Result(Nil, String)
