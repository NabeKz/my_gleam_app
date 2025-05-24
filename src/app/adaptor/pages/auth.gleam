import lib/http_core

pub fn signin(_req: http_core.Request) {
  "
  <div>
    <h1>signin</h1>
    <label for=id>
      id
      <div><input id=id /><div>
    </label>
    <label for=password>
      password
      <div><input id=password /><div>
    </label>
  </div>
  "
}
