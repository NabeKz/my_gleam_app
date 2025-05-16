import app/features/ticket/usecase/ticket_created
import app/features/ticket/usecase/ticket_deleted
import app/features/ticket/usecase/ticket_listed
import app/features/ticket/usecase/ticket_searched

pub const listed = ticket_listed.invoke

pub const created = ticket_created.invoke

pub const searched = ticket_searched.invoke

pub const deleted = ticket_deleted.invoke
