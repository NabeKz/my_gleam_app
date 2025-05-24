import gleam/list
import gleam/string

pub type Html

pub fn escape(value: String) -> String {
  "\"" <> value <> "\""
}

pub fn table(t_head: List(String), t_data: List(String)) -> String {
  ""
  |> string.append("<table>")
  |> string.append(t_head |> to_string())
  |> string.append(t_data |> to_string())
  |> string.append("</table>")
}

pub fn th(items: List(String)) -> List(String) {
  items
  |> list.map(fn(it) { "<th>" <> it <> "</th>" })
}

pub fn td(items: List(List(String))) -> List(String) {
  let f = fn(it) { "<td>" <> it <> "</td>" }
  items
  |> list.flat_map(fn(item) {
    let td = list.map(item, f) |> to_string()
    ["<tr>", td, "</tr>"]
  })
}

fn to_string(items: List(String)) -> String {
  items |> string.join("")
}

pub fn failure(errors: List(#(String, String))) -> String {
  let items =
    list.map(errors, fn(it) { "<li>" <> it.0 <> " " <> it.1 <> "</li>" })
    |> string.join("\n")

  "<ul>" <> items <> "</ul>"
}

pub fn div(tag: String) -> String {
  "<div>" <> tag <> "</div>"
}

pub fn form(method: String, action: String, tag: String) -> String {
  let head =
    "<form method=$method action=$action>"
    |> string.replace("$method", method)
    |> string.replace("$action", action)

  head
  <> tag
  <> "<div style=padding-top:10px>"
  <> "  <button>submit</button>"
  <> "</div>"
  <> "</form>"
}
