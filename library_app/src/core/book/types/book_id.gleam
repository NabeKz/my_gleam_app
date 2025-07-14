import shell/shared/lib/uuid

pub opaque type BookId {
  BookId(value: String)
}

pub fn to_string(vo: BookId) -> String {
  vo.value
}

pub fn from_string(value: String) -> BookId {
  BookId(value)
}

pub fn new() -> BookId {
  BookId(uuid.v4())
}
