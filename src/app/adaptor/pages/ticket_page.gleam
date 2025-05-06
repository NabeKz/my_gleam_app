import gleam/list
import gleam/string

import app/features/ticket/usecase/ticket_listed
import lib/http_core

const header = "<h1> tickets </h1>"

const form = "
  <form action=/tickets method=GET >
    <div>
      <label>
        title
      </label>
      <input name=title />
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
  header <> form <> body
}

fn success(items: List(ticket_listed.Dto)) -> String {
  let items = list.map(items, fn(it) { [it.title, it.created_at] })

  table(t_head(["title", "created_at"]), t_data(items))
}

fn failure(errors: List(#(String, String))) -> String {
  let items =
    list.map(errors, fn(it) { "<li>" <> it.0 <> " " <> it.1 <> "</li>" })
    |> string.join("\n")

  "<ul>" <> items <> "</ul>"
}

fn table(t_head: List(String), t_data: List(String)) -> String {
  ""
  |> string.append("<table>")
  |> string.append(t_head |> to_string())
  |> string.append(t_data |> to_string())
  |> string.append("</table>")
}

fn t_head(items: List(String)) -> List(String) {
  items
  |> list.map(fn(it) { "<th>" <> it <> "</th>" })
}

fn t_data(items: List(List(String))) -> List(String) {
  let f = fn(it) { "<td>" <> it <> "</td>" }
  items
  |> list.flat_map(fn(item) {
    let td = list.map(item, f) |> to_string()
    ["<tr>", td, "</tr>"]
  })
}

fn to_string(data: List(String)) -> String {
  data |> string.join("")
}
