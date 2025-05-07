import app/features/ticket/domain

pub type Dto {
  Dto(id: String, title: String, status: String)
}

pub type ErrorMessage {
  InvalidPath
  NotFound
}

pub type Workflow =
  fn(String) -> Result(Nil, List(ErrorMessage))

//
pub fn invoke(
  id: String,
  event: domain.TicketDeleted,
) -> Result(Nil, List(ErrorMessage)) {
  let result = {
    let ticket_id = id |> domain.ticket_id

    case event(ticket_id) {
      Ok(ticket) -> Ok(ticket)
      Error(_) -> Error(NotFound)
    }
  }

  case result {
    Ok(_) -> Ok(Nil)
    Error(err) -> Error([err])
  }
}
