import app/adaptor/pages/shared/html
import app/features/ticket/domain
import app/features/ticket/usecase/ticket_created
import app/features/ticket/usecase/ticket_searched
import gleam/dict
import gleam/dynamic
import gleam/string
import lib/http_core

const header = "<h1> tickets </h1>"

const form = "
  <form action=/tickets/create method=POST >
    <div>
      <label>title</label>
      <div><input name=title value=$1 /></div>
    </div>
    <div>
      <label>description</label>
      <div><input name=description value=$2 /></div>
    </div>
    <div style=padding-top:10px>
      <button type=submit> submit </button>
    </div>
  </form>
"

pub fn get(id: String, usecase: ticket_searched.Workflow) -> String {
  let body = case usecase(id) {
    Ok(ticket) -> success(ticket)
    Error([error, _]) -> failure(error)
    _ -> failure(ticket_searched.NotFound)
  }

  header <> body
}

fn success(item: ticket_searched.Dto) -> String {
  form
  |> string.replace("$1", item.title)
  |> string.replace("$2", item.description)
}

fn failure(error: ticket_searched.ErrorMessage) -> String {
  let message = case error {
    ticket_searched.InvalidPath -> "invalid path"
    ticket_searched.NotFound -> "not found"
  }

  "<ul>" <> message <> "</ul>"
}
