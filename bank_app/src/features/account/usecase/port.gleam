import features/account/domain/aggregate
import features/account/usecase/error

pub type LoadEvents =
  fn(String) -> Result(List(aggregate.CounterEvent), error.AppError)

pub type AppendEvents =
  fn(String, List(aggregate.CounterEvent)) -> Result(Nil, error.AppError)

pub type Usecase {
  Usecase(deposit: Deposit)
}

pub type Deposit =
  fn() -> Result(aggregate.Counter, error.AppError)
