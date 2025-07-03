import gleam/dict
import gleam/dynamic
import gleam/string

import app/adaptor/pages/shared/html
import app/features/ticket/domain/ticket_id
import app/features/ticket/usecase/ticket_searched
import app/features/ticket/usecase/ticket_updated
import lib/http_core

const header = "<h1> tickets </h1>"

const form = "
  <form action=/tickets/$id/edit method=POST >
    <div>
      <label>title</label>
      <div><input name=title value=$title /></div>
    </div>
    <div>
      <label>description</label>
      <div><input name=description value=$description /></div>
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

pub fn post(
  req: http_core.Request,
  id: String,
  usecase: ticket_updated.Workflow,
) -> String {
  let form = http_core.require_form(req)
  let form = form.values |> dict.from_list |> dynamic.from

  case usecase(id)(form) {
    Ok(id) -> id |> ticket_id.to_string |> update_success()
    Error(_) -> "failure"
  }
}

fn success(item: ticket_searched.Dto) -> String {
  form
  |> string.replace("$id", item.id)
  |> string.replace("$title", item.title |> html.escape)
  |> string.replace("$description", item.description |> html.escape())
}

fn update_success(id: String) -> String {
  " 
    <div>
      updated id is $id
    </div>
    <div>
      <a href=/tickets > back </a>
    </div>
  "
  |> string.replace("$id", id)
}

fn failure(error: ticket_searched.ErrorMessage) -> String {
  let message = case error {
    ticket_searched.InvalidPath -> "invalid path"
    ticket_searched.NotFound -> "not found"
  }

  "<ul>" <> message <> "</ul>"
}
