import wisp

import core/shared/types/auth
import core/shared/types/user

pub fn invoke() -> auth.AuthContext {
  fn(_req: wisp.Request) -> Result(user.User, String) {
    let user = user.User(user.id_from_string("dummy"))
    Ok(user)
  }
}
