import gleam/list
import gleam/string

import app/ticket/usecase/ticket_listed
import lib/http_core

const header = "<h1> tickets </h1>"

const form = "
  <form action=/tickets method=POST >
    <div>
      <div>
        <label>
          title
        </label>
      </div>
      <input />
    </div>
    
    <div>
      <div>
        <label>
          description
        </label>
      <div>
      <textarea></textarea>
    </div>

    <button type=submit> submit </button>
  </form>
"

pub fn get(req: http_core.Request, listed: ticket_listed.Workflow) -> String {
  let params = req |> http_core.get_query()

  let body = case listed(params) {
    Ok(tickets) -> success(tickets)
    Error(errors) -> failure(errors)
  }

  "
    <h1>
      tickets
    </h1>
    " <> body
}

fn success(items: List(ticket_listed.Dto)) -> String {
  let items = list.map(items, fn(it) { [it.title, it.created_at] })
  "
  <table>
  " <> t_head(["title", "created_at"]) <> t_data(items) <> "</table>"
}

fn failure(errors: List(#(String, String))) -> String {
  let items =
    list.map(errors, fn(it) { "<li>" <> it.0 <> " " <> it.1 <> "</li>" })
    |> string.join("\n")

  "<ul>" <> items <> "</ul>"
}

fn table(t_header: String, items: List(List(String))) -> String {
  "<table>" <> t_header <> "</table>"
}

fn t_head(items: List(String)) -> String {
  list.map(items, fn(it) { "<th>" <> it <> "</th>" })
  |> string.join("")
}

fn t_data(items: List(List(String))) -> String {
  list.map(items, fn(item) {
    let td = list.map(item, fn(it) { td(it) }) |> string.join("")
    "<tr>" <> td <> "</tr>"
  })
  |> string.join("")
}

fn td(value: String) -> String {
  "<td>" <> value <> "</td>"
}
