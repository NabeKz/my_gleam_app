import app/person/person.{type PersonRepository}
import app/person/person_repository_on_memory as person_repository
import app/ticket/infra/ticket_repository_on_memory
import app/ticket/ticket_controller
import app/ticket/usecase/ticket_listed

pub type Context {
  Context(person: PersonRepository, ticket: ticket_controller.Resolver)
}

pub fn new() -> Context {
  let ticket =
    ticket_repository_on_memory.new().list
    |> ticket_listed.register()
    |> ticket_controller.Resolver()

  Context(person: person_repository.new(), ticket:)
}
