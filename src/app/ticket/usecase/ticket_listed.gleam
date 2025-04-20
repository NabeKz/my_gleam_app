import app/ticket/domain
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import lib/date_time

type ErrorMessage {
  InvalidParam(List(#(String, String)))
}

pub type Dto {
  Dto(id: String, title: String, status: String)
}

pub type UnValidateSearchParams {
  UnValidateSearchParams(status: Option(String), created_at: Option(String))
}

pub type Workflow =
  fn(List(#(String, String))) -> Result(json.Json, String)

pub fn invoke(
  params: List(#(String, String)),
  command: domain.TicketListed,
) -> Result(json.Json, String) {
  let result = {
    use validate_params <- result.try(params |> parse() |> validate())
    validate_params |> Ok()
  }

  case result {
    Ok(result) ->
      result
      |> command()
      |> decode()
      |> deserialize()
      |> Ok()
    Error(_) -> Error("invalid params")
  }
}

fn parse(params: List(#(String, String))) -> UnValidateSearchParams {
  let find = list.key_find(params, _)

  UnValidateSearchParams(
    status: find("status") |> option.from_result,
    created_at: find("created_at") |> option.from_result,
  )
}

fn validate(
  params: UnValidateSearchParams,
) -> Result(domain.ValidateSearchParams, String) {
  let result = {
    let status = case params.status {
      Some(value) -> {
        use status <- result.try(value |> domain.ticket_status)
        status |> Some() |> Ok()
      }
      None -> None |> Ok()
    }

    let created_at = case params.created_at {
      option.Some(value) -> {
        use created_at <- result.try(value |> date_time.from_string)
        created_at |> option.Some() |> Ok()
      }
      option.None -> option.None |> Ok()
    }

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

fn decode(items: List(domain.Ticket)) -> List(Dto) {
  list.map(items, fn(item) {
    Dto(
      id: item.id |> domain.decode,
      title: item.title,
      status: to_string(item.status),
    )
  })
}

fn deserialize(items: List(Dto)) -> json.Json {
  json.array(items, fn(item) {
    json.object([
      #("id", json.string(item.id)),
      #("title", json.string(item.title)),
      #("status", json.string(item.status)),
    ])
  })
}
