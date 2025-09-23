import shared/db

pub type Context {
  Context(connection: db.Connection)
}
