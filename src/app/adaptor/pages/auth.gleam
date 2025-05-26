import app/adaptor/pages/shared/html
import gleam/result
import lib/http_core

const form = "
  <label for=id>
    id
    <div><input name=id id=id /><div>
  </label>
  <label for=password>
    password
    <div><input name=password id=password /><div>
  </label>
"

pub fn signin(req: http_core.Request) {
  let cookie =
    req |> http_core.get_cookie_with_plan_text("errors") |> result.unwrap("")

  let form = html.form("POST", "/signin", form)

  case cookie {
    "" -> html.div("<h1>signin</h1>" <> form)
    _ -> html.div(cookie) <> html.div("<h1>signin</h1>" <> form)
  }
}
