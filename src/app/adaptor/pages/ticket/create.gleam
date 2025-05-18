import app/features/ticket/domain
import app/features/ticket/usecase/ticket_created
import gleam/dict
import gleam/dynamic
import gleam/string
import lib/http_core

const header = "<h1> tickets </h1>"

const form = "
  <form action=/tickets/create method=POST >
    <div>
      <label>title</label>
      <div><input name=title /></div>
    </div>
    <div>
      <label>description</label>
      <div><input name=description /></div>
    </div>
    <div style=padding-top:10px>
      <button type=submit> submit </button>
    </div>
  </form>
"

pub fn get(_req: http_core.Request) -> String {
  header <> form
}

pub fn post(req: http_core.Request, usecase: ticket_created.Workflow) -> String {
  let form = http_core.require_form(req)
  let result = form.values |> dict.from_list |> dynamic.from |> usecase()

  case result {
    Ok(id) -> domain.decode(id) |> create_success()
    Error(_) -> "failure"
  }
}

fn create_success(id: String) -> String {
  [
    "<div>",
    "  created id is " <> id,
    "</div>",
    "<div>",
    "  <a href=/tickets > back </a>",
    "</div>",
  ]
  |> string.join("")
}
