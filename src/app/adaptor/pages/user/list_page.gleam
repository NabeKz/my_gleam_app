import gleam/list

import app/adaptor/pages/shared/html
import app/features/user/user
import lib/http_core

const header = "<h1> users </h1>"

const form = "
  <form action=/users method=GET >
    <div>
      <label>
        name
      </label>
      <input name=name />
    </div>
    <button type=submit> submit </button>
  </form>
"

pub fn get(_req: http_core.Request, usecase: user.Listed) -> String {
  let body = case usecase() {
    Ok(items) -> success(items)
    Error(_) -> html.failure([#("error", "error")])
  }
  header <> form <> body
}

pub fn success(items: List(user.UserReadModel)) -> String {
  let items = list.map(items, fn(it) { [it.name, it.favorite_color] })

  html.table(html.th(["name", "favorite_color"]), html.td(items))
}
