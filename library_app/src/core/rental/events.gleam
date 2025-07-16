import core/shared/types/date

pub type LentEvent {
  BookLend(
    event_id: String,
    book_id: String,
    renter_id: String,
    rented_at: date.Date,
    due_date: date.Date,
    // イベント発生時刻
    timestamp: date.Date,
  )
  BookReturned
}
