import app/ticket/domain
import app/ticket/usecase/ticket_created
import gleam/dynamic/decode
import gleam/http
import gleam/json
import gleam/result
import wisp

pub type Usecase {
  Usecase(ticket_listed: domain.TicketListed)
}

pub fn routes(req: wisp.Request, usecase: Usecase) -> wisp.Response {
  case wisp.path_segments(req), req.method {
    [], http.Get -> get_controller(req, usecase.ticket_listed)
    [], http.Post -> post_controller(req)
    _, _ -> wisp.not_found()
  }
}

fn get_controller(
  _req: wisp.Request,
  ticket_listed: domain.TicketListed,
) -> wisp.Response {
  ticket_listed()
  |> json.array(fn(item) {
    json.object([
      #("id", json.string(item.id)),
      #("title", json.string(item.id)),
      #("status", json.string(item.id)),
    ])
  })
  |> json.to_string_tree()
  |> wisp.json_response(200)
}

fn post_controller(req: wisp.Request) -> wisp.Response {
  use json <- wisp.require_json(req)

  let result = {
    use dto <- result.try(decode.run(json, decode_ticket()))
    todo
  }

  json.string("ok")
  |> json.to_string_tree()
  |> wisp.json_response(201)
}

fn decode_ticket() -> decode.Decoder(ticket_created.Dto) {
  use title <- decode.field("title", decode.string)

  decode.success(ticket_created.Dto(title:))
}
