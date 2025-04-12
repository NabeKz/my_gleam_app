import app/person/person.{type PersonRepository}
import app/person/person_repository_on_memory as person_repository
import app/ticket/ticket_controller
import app/ticket/usecase/ticket_listed

pub type Context {
  Context(person: PersonRepository, ticket: ticket_controller.Usecase)
}

pub fn new() -> Context {
  Context(
    person: person_repository.new(),
    ticket: ticket_controller.Usecase(ticket_listed: ticket_listed.invoke),
  )
}
