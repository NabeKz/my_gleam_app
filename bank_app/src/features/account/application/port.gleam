import features/account/application/error
import features/account/domain/aggregate

pub type LoadEvents =
  fn(String) -> Result(List(aggregate.AccountEvent), error.AppError)

pub type AppendEvents =
  fn(String, List(aggregate.AccountEvent)) -> Result(Nil, error.AppError)

pub type Create =
  fn() -> Result(AggregateContext(aggregate.Account), error.AppError)

pub type Deposit =
  fn() -> Result(AggregateContext(aggregate.Account), error.AppError)

pub type AggregateContext(t) {
  AggregateContext(data: t, version: Int)
}
