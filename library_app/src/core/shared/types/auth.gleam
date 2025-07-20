import gleam/list
import gleam/string
import wisp

import gleam/result

import core/shared/types/user

pub type AuthContext =
  fn(wisp.Request) -> Result(user.User, String)

pub fn authenticated(
  req: wisp.Request,
  get_users: fn(String) -> Result(user.User, String),
) -> Result(user.User, String) {
  req.headers
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
    [token] -> Ok(token)
    _ -> Error("不正なフォーマットです")
  }
}
