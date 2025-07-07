pub type Signin =
  fn(Form) -> Bool

pub type Form {
  Form(email: String, password: String)
}

pub fn signin() -> Result(String, String) {
  // TODO: Integrate with external auth service (e.g., Cognito)
  Error("Not implemented")
}

pub fn signout() -> Result(Nil, String) {
  // TODO: Integrate with external auth service (e.g., Cognito)
  Error("Not implemented")
}

pub fn signup() -> Result(String, String) {
  // TODO: Integrate with external auth service (e.g., Cognito)
  Error("Not implemented")
}
