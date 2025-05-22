import app/features/auth/domain
import lib/storage

const table = "auth"

fn authenticated(form form: domain.Form) -> Bool {
  case storage.get(table, form.email) {
    Ok(_) -> True
    _ -> False
  }
}

pub const signin: domain.Signin = authenticated
