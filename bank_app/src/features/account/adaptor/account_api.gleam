import gleam/int
import wisp

import features/account/domain/aggregate
import features/account/usecase/error
import features/account/usecase/port

pub fn post(usecase: port.Usecase) -> wisp.Response {
  case usecase.deposit() {
    Ok(counter) -> respond_created(counter)
    Error(err) -> respond_error(err)
  }
}

fn respond_created(counter: aggregate.Counter) -> wisp.Response {
  let body = aggregate.value(counter) |> int.to_string()

  wisp.response(201)
  |> wisp.string_body(body)
}

fn respond_error(err: error.AppError) -> wisp.Response {
  wisp.bad_request(error_message(err))
}

fn error_message(err: error.AppError) -> String {
  case err {
    error.LoadFailed(message) -> message
    error.AppendFailed(message) -> message
  }
}

fn resolve_event(_req: wisp.Request) -> aggregate.CounterEvent {
  aggregate.Upped
}
