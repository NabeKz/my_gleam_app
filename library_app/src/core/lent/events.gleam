import core/shared/types/date
import shell/shared/lib/uuid

// MEMO: 入れ子構造なのは各イベント型が独立してバリデーション可能にするため
pub type LentEvent {
  BookLendEvent(BookLend)
  BookReturnedEvent(BookReturned)
}

pub type BookLend {
  BookLend(
    event_id: String,
    book_id: String,
    renter_id: String,
    rented_at: date.Date,
    due_date: date.Date,
    // イベント発生時刻（監査・ログ用）
    timestamp: date.Timestamp,
  )
}

pub type BookReturned {
  BookReturned(
    event_id: String,
    book_id: String,
    renter_id: String,
    returned_at: date.Date,
    timestamp: date.Timestamp,
  )
}

pub fn is_same_book_id(event: LentEvent, book_id: String) -> Bool {
  get_book_id(event) == book_id
}

pub fn event_timestamp(event: LentEvent) -> date.Timestamp {
  case event {
    BookLendEvent(e) -> e.timestamp
    BookReturnedEvent(e) -> e.timestamp
  }
}

fn get_book_id(event: LentEvent) -> String {
  case event {
    BookLendEvent(e) -> e.book_id
    BookReturnedEvent(e) -> e.book_id
  }
}

pub fn new_event_id() -> String {
  uuid.v4()
}
