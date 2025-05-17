import app/features/ticket/usecase/ticket_created
import gleam/json
import gleam/list
import gleam/result
import gleam/string

import app/features/ticket/usecase/ticket_listed
import lib/http_core

const header = "<h1> tickets </h1>"

const form = "
  <form action=/tickets method=POST >
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

// pub fn post(req: http_core.Request, usecase: ticket_created.Workflow) -> String {
//   let json = req |> http_core.require_json(fn(it) { it |> Ok() })

//   case result {
//     Ok(id) -> "success"
//     Error(_) -> "failure"
//   }
// }

fn success(items: List(ticket_listed.Dto)) -> String {
  let items = list.map(items, fn(it) { [it.id, it.title, it.created_at] })

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
    let #(id, rest) = slice(item)
    let td =
      list.map(rest, f)
      |> list.append([
        "<td>",
        "  <form action=/tickets/" <> id <> " method=POST >",
        "    <button type=submit> delete </button>",
        "  </form>",
        "</td>",
      ])
      |> to_string()

    ["<tr>", td, "</tr>"]
  })
}

fn slice(items: List(String)) {
  let id = list.first(items)
  let rest = list.rest(items)
  case id, rest {
    Ok(id), Ok(items) -> #(id, items)
    _, _ -> #("", [])
  }
}

fn to_string(data: List(String)) -> String {
  data |> string.join("")
}
