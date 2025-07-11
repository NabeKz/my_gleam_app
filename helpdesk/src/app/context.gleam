import app/adaptor/api/ticket_controller
import app/features/ticket/infra/ticket_repository_on_ets
import app/features/ticket/infra/ticket_repository_on_memory
import app/features/ticket/infra/ticket_repository_on_process
import app/features/ticket/infra/ticket_repository_on_sqlite
import app/features/ticket/ticket_usecase
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
      listed: ticket_usecase.listed(_, ticket_repository_on_sqlite.list(db, _)),
      created: ticket_usecase.created(ticket_repository.create, _),
      searched: ticket_usecase.searched(_, ticket_repository.find),
      updated: ticket_usecase.updated(
        _,
        ticket_repository.find,
        ticket_repository.update,
      ),
      deleted: ticket_usecase.deleted(_, ticket_repository.delete),
    )

  Context(auth:, user:, ticket:)
}

pub fn on_ets() -> Context {
  let auth = ""
  let user = user_repository.new()

  let ticket_repository = ticket_repository_on_ets.new()
  let ticket_process = ticket_repository_on_process.new()
  let ticket =
    ticket_controller.Resolver(
      listed: ticket_usecase.listed(_, ticket_process.list),
      created: ticket_usecase.created(ticket_process.create, _),
      searched: ticket_usecase.searched(_, ticket_repository.find),
      updated: ticket_usecase.updated(
        _,
        ticket_repository.find,
        ticket_repository.update,
      ),
      deleted: ticket_usecase.deleted(_, ticket_repository.delete),
    )

  Context(auth:, user:, ticket:)
}

pub fn mock() -> Context {
  let auth = ""
  let user = user_repository.new()

  let ticket_repository = ticket_repository_on_memory.new([])
  let ticket =
    ticket_controller.Resolver(
      listed: ticket_usecase.listed(_, ticket_repository.list),
      created: ticket_usecase.created(ticket_repository.create, _),
      searched: ticket_usecase.searched(_, ticket_repository.find),
      updated: ticket_usecase.updated(
        _,
        ticket_repository.find,
        ticket_repository.update,
      ),
      deleted: ticket_usecase.deleted(_, ticket_repository.delete),
    )

  Context(auth:, user:, ticket:)
}
