import features/account/domain/aggregate

// TODO: impl Error type
pub type LoadEvents =
  fn(String) -> Result(List(aggregate.CounterEvent), String)

pub type AppendEvents =
  fn(String, List(aggregate.CounterEvent)) -> Result(Nil, String)
