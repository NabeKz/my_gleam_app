import core/shared/types/date

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
  BookReturnedEvent(
    event_id: String,
    book_id: String,
    renter_id: String,
    returned_at: date.Date,
    timestamp: date.Timestamp,
  )
}
