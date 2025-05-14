import gleam/list
import gleam/string

import app/features/ticket/usecase/ticket_searched

const header = "<h1> tickets </h1>"

pub fn delete(id: String, usecase: ticket_searched.Workflow) -> String {
  let body = case usecase(id) {
    Ok(tickets) -> success(tickets)
    Error([error, _]) -> failure(error)
    _ -> failure(ticket_searched.NotFound)
  }
  header <> body
}

fn success(item: ticket_searched.Dto) -> String {
  let items = [
    item.id,
    item.title,
    item.description,
    item.status,
    item.created_at,
  ]

  use data <- table(items)

  li(data)
}

fn failure(error: ticket_searched.ErrorMessage) -> String {
  let message = case error {
    ticket_searched.InvalidPath -> "invalid path"
    ticket_searched.NotFound -> "not found"
  }

  "<ul>" <> message <> "</ul>"
}

fn table(li: List(String), f: fn(List(String)) -> List(String)) -> String {
  ""
  |> string.append("<ul>")
  |> string.append(f(li) |> string.join(""))
  |> string.append("</ul>")
}

fn li(items: List(String)) -> List(String) {
  items
  |> list.map(fn(it) { "<li>" <> it <> "</li>" })
}
