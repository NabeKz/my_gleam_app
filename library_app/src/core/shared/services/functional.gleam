pub fn thunk(f: a) -> fn() -> a {
  fn() { f }
}
