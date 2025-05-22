import app/adaptor/pages/shared/html
import gleam/list
import gleam/string

import app/features/ticket/usecase/ticket_searched

const header = "<h1> tickets </h1>"

const back = "<a href=/tickets> back </a>"

const link = "<a href=/tickets/$id/edit> edit </a>"

pub fn get(id: String, usecase: ticket_searched.Workflow) -> String {
  let body = case usecase(id) {
    Ok(tickets) -> success(tickets)
    Error([error, _]) -> failure(error)
    _ -> failure(ticket_searched.NotFound)
  }
  header <> html.div(back) <> body
}

fn success(item: ticket_searched.Dto) -> String {
  let items = [
    #("id", item.id),
    #("title", item.title),
    #("description", item.description),
    #("status", item.status),
    #("created_at", item.created_at),
  ]

  let body = {
    use data <- list(items)
    li(data)
  }
  let link = link |> string.replace("$id", item.id)
  html.div(link) <> body
}

fn failure(error: ticket_searched.ErrorMessage) -> String {
  let message = case error {
    ticket_searched.InvalidPath -> "invalid path"
    ticket_searched.NotFound -> "not found"
  }
  "<ul>" <> message <> "</ul>"
}

fn list(
  li: List(#(String, String)),
  f: fn(List(#(String, String))) -> List(String),
) -> String {
  ""
  |> string.append("<div>")
  |> string.append(f(li) |> string.concat)
  |> string.append("</div>")
}

fn li(items: List(#(String, String))) -> List(String) {
  items
  |> list.map(fn(it) {
    "
      <h2>$it0</h2>
      <span>$it1</span>
    "
    |> string.replace("$it0", it.0)
    |> string.replace("$it1", it.1)
  })
}
