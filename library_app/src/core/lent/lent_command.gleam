import core/book/book
import core/lent/events
import core/lent/lent_state
import core/shared/types/date
import gleam/result

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

pub fn handle_lent_book_command(
  command: LentBookCommand,
  get_events: GetEventsByBook,
  append_event: AppendEvent,
  check_book_exists: book.CheckBookExists,
  current_date: date.GetDate,
) {
  use _ <- result.try(check_book_exists(command.book_id))
  let current_state =
    command.book_id
    |> lent_state.calculate_lent_state(get_events(command.book_id))

  case current_state {
    lent_state.Lend(..) -> Error("この本は既に貸出中です")
    lent_state.Available -> {
      let lent_event =
        events.BookLendEvent(
          event_id: events.new_event_id(),
          book_id: command.book_id,
          renter_id: command.renter_id,
          rented_at: current_date(),
          due_date: current_date() |> date.add_days(14),
          timestamp: current_date(),
        )
      use _ <- result.try(append_event(events.BookLend(lent_event)))
      Ok(lent_event)
    }
  }
}

pub fn handle_return_book_command(
  command: ReturnBookCommand,
  get_events: GetEventsByBook,
  append_event: AppendEvent,
  current_date: date.GetDate,
) -> Result(events.BookReturnedEvent, String) {
  let current_state =
    command.book_id
    |> lent_state.calculate_lent_state(get_events(command.book_id))

  case current_state {
    lent_state.Available -> Error("この本は貸出されていません")
    lent_state.Lend(renter_id) if renter_id != command.renter_id ->
      Error("この本は他の人に貸出されています")
    lent_state.Lend(renter_id) -> {
      let return_event =
        events.BookReturnedEvent(
          event_id: events.new_event_id(),
          book_id: command.book_id,
          renter_id: renter_id,
          returned_at: current_date(),
          timestamp: current_date(),
        )
      use _ <- result.try(append_event(events.BookReturned(return_event)))
      Ok(return_event)
    }
  }
}
