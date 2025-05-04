import lib/http_core

pub fn handle_request(_req: http_core.Request) -> String {
  "
    <h1>
      tickets
    </h1>

    <form action=/tickets method=POST >
      <div>
        <div>
          <label>
            title
          </label>
        </div>
        <input />
      </div>
      
      <div>
        <div>
          <label>
            description
          </label>
        <div>
        <textarea></textarea>
      </div>

      <button type=submit> submit </button>
    </form>
  "
}
