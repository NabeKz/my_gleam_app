import app/adaptor/api/ticket_controller

pub fn ticket_resolver_mock() {
  ticket_controller.Resolver(
    listed: fn(_) { Error([]) },
    created: fn(_) { Error([]) },
    searched: fn(_) { Error([]) },
    deleted: fn(_) { Error([]) },
    updated: fn(_) { Error([]) },
  )
}
