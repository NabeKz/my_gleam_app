import shared/db/db

pub type Context {
  Context(connection: db.Connection)
}
