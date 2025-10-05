import youid/uuid

pub type Generate =
  fn() -> String

pub fn v4() -> String {
  uuid.v4() |> uuid.to_string()
}
