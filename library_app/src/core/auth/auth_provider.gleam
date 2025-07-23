import gleam/list
import gleam/result
import gleam/string

import core/shared/types/auth
import core/shared/types/user

pub fn on_mock() -> auth.AuthContext {
  fn(params: List(#(String, String))) -> Result(user.User, String) {
    let params =
      {
        use #(key, _) <- list.find(params)
        string.lowercase(key) == "authorization"
      }
      |> result.replace_error("authorization header not found")
    let params = result.map(params, fn(it) { it.1 == "dummy" })
    case params {
      Ok(True) -> {
        user.User(user.id_from_string("dummy"))
        |> Ok()
      }
      _ -> Error("invalid header")
    }
  }
}

pub fn on_request(
  headers: List(#(String, String)),
  get_users: fn(String) -> Result(user.User, String),
) -> Result(user.User, String) {
  headers
  |> parse_auth_token()
  |> result.map(get_users)
  |> result.flatten()
}

fn parse_auth_token(headers: List(#(String, String))) -> Result(String, String) {
  use header <- result.try(headers |> get_token())
  use header <- result.try(header |> get_authorization_token())
  Ok(header)
}

fn get_token(headers: List(#(String, String))) -> Result(String, String) {
  let header =
    list.find(headers, get_authorization_header)
    |> result.replace_error("トークンが見つかりません")

  use #(_, token) <- result.map(header)
  token
}

fn get_authorization_header(header: #(String, String)) {
  let #(key, _) = header
  string.lowercase(key) == "authorization"
}

fn get_authorization_token(raw_token: String) -> Result(String, String) {
  case string.split(raw_token, "Bearer ") {
    [_, token] -> Ok(token)
    _ -> Error("不正なフォーマットです")
  }
}
