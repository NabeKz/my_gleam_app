import app/ticket/domain.{type TicketCreated, type TicketId}

pub type Dto {
  Dto(title: String)
}

pub fn invoke(event: TicketCreated, dto: Dto) -> TicketId {
  domain.new_ticket(id: "", title: dto.title, created_at: "")
  |> event()
}
