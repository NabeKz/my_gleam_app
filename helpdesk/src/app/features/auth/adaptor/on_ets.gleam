import app/features/auth/domain
import lib/storage

fn authenticated(form form: domain.Form) -> Bool {
  let empty: List(domain.Form) = []
  let conn = storage.conn("auth", empty, fn(it) { it.email })
  case conn.get(form.email) {
    Ok(_) -> True
    _ -> False
  }
}

pub const signin: domain.Signin = authenticated
