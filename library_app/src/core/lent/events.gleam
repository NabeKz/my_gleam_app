import core/shared/types/date
import shell/shared/lib/uuid

pub type LentEvent {
  BookLend(
    event_id: String,
    book_id: String,
    renter_id: String,
    rented_at: date.Date,
    due_date: date.Date,
    // イベント発生時刻（監査・ログ用）
    timestamp: date.Timestamp,
  )
  BookReturned(
    event_id: String,
    book_id: String,
    renter_id: String,
    returned_at: date.Date,
    timestamp: date.Timestamp,
  )
}

pub fn new_event_id() -> String {
  uuid.v4()
}
