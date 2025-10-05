import features/account/application/error
import features/account/domain/aggregate

pub type LoadEvents =
  fn(String) -> Result(EventStream(aggregate.AccountEvent), error.AppError)

pub type AppendEvents =
  fn(String, Int, List(aggregate.AccountEvent)) -> Result(Nil, error.AppError)

pub type Create =
  fn() -> Result(AggregateContext(aggregate.Account), error.AppError)

pub type Deposit =
  fn() -> Result(AggregateContext(aggregate.Account), error.AppError)

pub type AggregateContext(t) {
  AggregateContext(data: t, version: Int)
}

pub type EventStream(t) {
  EventStream(events: List(t), version: Int)
}
