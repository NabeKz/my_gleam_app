import shell/shared/lib/uuid

pub type User {
  User(id: UserId)
}

pub opaque type UserId {
  UserId(value: String)
}

pub fn new() -> User {
  User(UserId(uuid.v4()))
}

pub fn id_from_string(value: String) -> UserId {
  UserId(value)
}

pub fn id_value(id: UserId) -> String {
  id.value
}
