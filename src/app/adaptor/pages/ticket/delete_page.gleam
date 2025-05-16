import app/features/ticket/usecase/ticket_deleted

const header = "<h1> tickets </h1>"

const footer = "<div><a href=/tickets > back </a><div>"

pub fn delete(id: String, usecase: ticket_deleted.Workflow) -> String {
  let body = case usecase(id) {
    Ok(_) -> success(id)
    Error([error, _]) -> failure(error)
    _ -> failure(ticket_deleted.NotFound)
  }
  header <> body <> footer
}

fn success(id) -> String {
  "id " <> id <> " is deleted"
}

fn failure(error: ticket_deleted.ErrorMessage) -> String {
  let message = case error {
    ticket_deleted.InvalidPath -> "invalid path"
    ticket_deleted.NotFound -> "not found"
  }

  "<ul>" <> message <> "</ul>"
}
