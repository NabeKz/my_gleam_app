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

pub fn get(_req: http_core.Request) -> String {
  let body = "success"
  header <> form <> body
}
