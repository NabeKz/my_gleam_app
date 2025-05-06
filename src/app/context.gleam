import app/adaptor/api/ticket_controller
import app/features/person/person.{type PersonRepository}
import app/features/person/person_repository_on_memory as person_repository
import app/features/ticket/infra/ticket_repository_on_memory
import app/features/ticket/usecase/ticket_created
import app/features/ticket/usecase/ticket_deleted
import app/features/ticket/usecase/ticket_listed
import app/features/ticket/usecase/ticket_searched

pub type Context {
  Context(person: PersonRepository, ticket: ticket_controller.Resolver)
}

pub fn new() -> Context {
  let ticket_repository = ticket_repository_on_memory.new([])
  let ticket =
    ticket_controller.Resolver(
      listed: ticket_listed.invoke(_, ticket_repository.list),
      created: ticket_created.invoke(ticket_repository.create, _),
      searched: ticket_searched.invoke(_, ticket_repository.find),
      deleted: ticket_deleted.invoke(_, ticket_repository.delete),
    )

  Context(person: person_repository.new(), ticket:)
}
