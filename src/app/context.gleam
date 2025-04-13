import app/person/person.{type PersonRepository}
import app/person/person_repository_on_memory as person_repository
import app/ticket/infra/ticket_repository_on_memory
import app/ticket/ticket_controller
import app/ticket/usecase/ticket_listed

pub type Context {
  Context(person: PersonRepository, ticket: ticket_controller.Usecase)
}

pub fn new() -> Context {
  let ticket =
    fn() {
      ticket_repository_on_memory.new().list
      |> ticket_listed.invoke()
    }
    |> ticket_controller.Usecase()

  Context(person: person_repository.new(), ticket:)
}
