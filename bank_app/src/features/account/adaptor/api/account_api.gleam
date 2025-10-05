import gleam/int
import wisp

import features/account/application/error
import features/account/application/port
import features/account/domain/aggregate

pub fn post(usecase: port.Create) -> wisp.Response {
  case usecase() {
    Ok(counter) -> respond_created(counter)
    Error(err) -> respond_error(err)
  }
}

fn respond_created(
  ctx: port.AggregateContext(aggregate.Account),
) -> wisp.Response {
  let body = aggregate.value(ctx.data) |> int.to_string()

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
