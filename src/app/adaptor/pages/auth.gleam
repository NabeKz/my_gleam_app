import app/adaptor/pages/shared/html
import lib/http_core

const form = "
  <label for=id>
    id
    <div><input id=id /><div>
  </label>
  <label for=password>
    password
    <div><input id=password /><div>
  </label>
"

pub fn signin(_req: http_core.Request) {
  let form = html.form("GET", "/siginin", form)

  html.div("<h1>signin</h1>" <> form)
}
