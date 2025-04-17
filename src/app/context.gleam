import app/person/person.{type PersonRepository}
import app/person/person_repository_on_memory as person_repository
import app/ticket/infra/ticket_repository_on_memory
import app/ticket/ticket_controller
import app/ticket/usecase/ticket_created
import app/ticket/usecase/ticket_listed
import app/ticket/usecase/ticket_searched

pub type Context {
  Context(person: PersonRepository, ticket: ticket_controller.Resolver)
}

pub fn new() -> Context {
  let ticket_repository = ticket_repository_on_memory.new()
  let ticket =
    ticket_controller.Resolver(
      listed: ticket_listed.invoke(ticket_repository.list, _),
      created: ticket_created.invoke(ticket_repository.create, _),
      searched: ticket_searched.invoke(_, ticket_repository.find),
    )

  Context(person: person_repository.new(), ticket:)
}
