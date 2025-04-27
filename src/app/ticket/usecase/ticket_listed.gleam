import app/ticket/domain
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

import lib/date_time
import lib/parser

type ErrorMessage =
  List(#(String, String))

pub type Dto {
  Dto(id: String, title: String, status: String, created_at: String)
}

pub type UnValidateSearchParams {
  UnValidateSearchParams(status: Option(String), created_at: Option(String))
}

type Params =
  List(#(String, String))

pub type Workflow =
  fn(Params) -> Result(json.Json, ErrorMessage)

pub fn invoke(
  params: Params,
  command: domain.TicketListed,
) -> Result(json.Json, ErrorMessage) {
  let result = {
    use validate_params <- result.try(params |> parse() |> validate())
    validate_params |> Ok()
  }

  case result {
    Ok(form) ->
      form
      |> command()
      |> apply(form)
      |> decode()
      |> deserialize()
      |> Ok()
    Error(_) -> [#("field", "invalid params")] |> Error()
  }
}

fn parse(params: List(#(String, String))) -> UnValidateSearchParams {
  let find = list.key_find(params, _)

  UnValidateSearchParams(
    // TODO: handle invalid status
    status: find("status") |> option.from_result,
    created_at: find("created_at") |> option.from_result,
  )
}

fn validate(
  params: UnValidateSearchParams,
) -> Result(domain.ValidateSearchParams, String) {
  let result = {
    let status = params.status |> parser.map_or(domain.ticket_status)
    let created_at = params.created_at |> parser.map_or(date_time.from_string)

    use status <- result.try(status)
    use created_at <- result.try(created_at)

    domain.ValidateSearchParams(status:, created_at:)
    |> Ok()
  }

  case result {
    Ok(params) -> Ok(params)
    Error(_) -> Error("invalid params")
  }
}

fn to_string(status: domain.TicketStatus) -> String {
  case status {
    domain.Open -> "open"
    domain.Progress -> "progress"
    domain.Close -> "close"
    domain.Done -> "done"
  }
}

fn apply(
  items: List(domain.Ticket),
  form: domain.ValidateSearchParams,
) -> List(domain.Ticket) {
  case form.status {
    Some(status) -> items |> list.filter(fn(item) { item.status == status })
    None -> items
  }
}

fn decode(items: List(domain.Ticket)) -> List(Dto) {
  list.map(items, fn(item) {
    Dto(
      id: item.id |> domain.decode,
      title: item.title,
      status: item.status |> to_string(),
      created_at: item.created_at,
    )
  })
}

fn deserialize(items: List(Dto)) -> json.Json {
  json.array(items, fn(item) {
    json.object([
      #("id", json.string(item.id)),
      #("title", json.string(item.title)),
      #("status", json.string(item.status)),
      #("created_at", json.string(item.created_at)),
    ])
  })
}
