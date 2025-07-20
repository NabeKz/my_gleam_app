import core/shared/types/user

pub type AuthContext =
  fn(List(#(String, String))) -> Result(user.User, String)
