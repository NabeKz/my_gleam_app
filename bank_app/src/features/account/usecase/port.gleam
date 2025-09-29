import features/account/domain

// TODO: impl Error type
pub type LoadEvents =
  fn(String) -> Result(List(domain.CounterEvent), String)

pub type AppendEvents =
  fn(String, List(domain.CounterEvent)) -> Result(Nil, String)
