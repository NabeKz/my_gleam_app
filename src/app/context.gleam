import app/adaptor/api/ticket_controller
import app/features/ticket/infra/ticket_repository_on_memory
import app/features/ticket/infra/ticket_repository_on_sqlite
import app/features/ticket/usecase/ticket_created
import app/features/ticket/usecase/ticket_deleted
import app/features/ticket/usecase/ticket_listed
import app/features/ticket/usecase/ticket_searched
import app/features/user/user
import app/features/user/user_repository_on_memory as user_repository
import lib/db

type Auth =
  String

pub type Context {
  Context(
    auth: Auth,
    user: user.UserRepository,
    ticket: ticket_controller.Resolver,
  )
}

pub fn new(db: db.Conn) -> Context {
  let auth = ""
  let user = user_repository.new()

  let ticket_repository = ticket_repository_on_memory.new([])
  let ticket =
    ticket_controller.Resolver(
      listed: ticket_listed.invoke(_, ticket_repository_on_sqlite.list(db, _)),
      created: ticket_created.invoke(ticket_repository.create, _),
      searched: ticket_searched.invoke(_, ticket_repository.find),
      deleted: ticket_deleted.invoke(_, ticket_repository.delete),
    )

  Context(auth:, user:, ticket:)
}

pub fn mock() -> Context {
  let auth = ""
  let user = user_repository.new()

  let ticket_repository = ticket_repository_on_memory.new([])
  let ticket =
    ticket_controller.Resolver(
      listed: ticket_listed.invoke(_, ticket_repository.list),
      created: ticket_created.invoke(ticket_repository.create, _),
      searched: ticket_searched.invoke(_, ticket_repository.find),
      deleted: ticket_deleted.invoke(_, ticket_repository.delete),
    )

  Context(auth:, user:, ticket:)
}
