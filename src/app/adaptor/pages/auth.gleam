import app/adaptor/pages/shared/html
import lib/http_core

pub fn signin(_req: http_core.Request) {
  "
  <div>
    <h1>signin</h1>
    <form action=/signin method=POST>
      <label for=id>
        id
        <div><input id=id /><div>
      </label>
      <label for=password>
        password
        <div><input id=password /><div>
      </label>
      " <> html.button("submit") <> "
    </form>
  </div>
  "
}
