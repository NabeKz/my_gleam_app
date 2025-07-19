import shell/shared/lib/uuid

pub type User {
  User(user_id: String)
}

pub fn new() -> User {
  User(uuid.v4())
}
