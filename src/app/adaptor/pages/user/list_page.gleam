import gleam/list

import app/adaptor/pages/shared/html
import app/features/user/user
import lib/http_core

const header = "<h1> users </h1>"

const form = "
  <form action=/users method=GET >
    <div>
      <label>
        title
      </label>
      <input name=title />
    </div>
    <button type=submit> submit </button>
  </form>
"

pub fn get(_req: http_core.Request) -> String {
  let body = "success"
  header <> form <> body
}

pub fn success(items: List(user.User)) -> String {
  let items = list.map(items, fn(it) { [it.name, it.favorite_color] })

  html.table(html.th(["name", "created_at"]), html.td(items))
}
