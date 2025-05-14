import app/features/auth/domain
import gleam/list
import lib/storage

const table = "auth"

fn authenticated(form form: domain.Form) -> Bool {
  storage.get(table, form.email)
  |> list.is_empty()
}

pub const signin: domain.Signin = authenticated
