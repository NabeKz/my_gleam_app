import app/ticket/domain.{type TicketCreated, type TicketId}
import lib/date_time

pub type Dto {
  Dto(title: String, description: String, status: String)
}

pub type Invoke =
  fn() -> Dto

pub fn invoke(dto: Dto, command: TicketCreated) -> TicketId {
  dto
  |> convert()
  |> command()
}

fn convert(dto: Dto) -> domain.TicketWriteModel {
  domain.TicketWriteModel(
    title: dto.title,
    description: dto.description,
    status: domain.Open,
    created_at: date_time.now() |> date_time.to_string(),
  )
}
