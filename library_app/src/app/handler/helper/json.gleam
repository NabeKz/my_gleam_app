import gleam/dynamic
import gleam/dynamic/decode
import gleam/json
import gleam/list
import wisp

import features/book/port/book_id
import features/loan/loan

pub fn ok(body: json.Json) -> wisp.Response {
  body
  |> json.to_string_tree()
  |> wisp.json_response(200)
}

pub fn bad_request(body: json.Json) -> wisp.Response {
  body
  |> json.to_string_tree()
  |> wisp.json_response(400)
}

// TODO: error handling
pub fn get_body(
  req: wisp.Request,
  decoder: fn() -> decode.Decoder(t),
  next: fn(t) -> wisp.Response,
) -> wisp.Response {
  use <- wisp.require_content_type(req, "application/json")
  use body <- wisp.require_string_body(req)
  case json.parse(body, decoder()) {
    Ok(json) -> next(json)
    Error(_) -> wisp.bad_request()
  }
}

// TODO: error handling
pub fn get_query(
  req: wisp.Request,
  decoder: fn() -> decode.Decoder(t),
  next: fn(t) -> wisp.Response,
) {
  let query = wisp.get_query(req)
  let query = {
    use it <- list.map(query)
    #(it.0 |> dynamic.string, it.1 |> dynamic.string)
  }
  let query = decode.run(query |> dynamic.properties, decoder())
  case query {
    Ok(query) -> next(query)
    Error(_) -> wisp.bad_request()
  }
}

pub fn array(deserialized: List(List(#(String, String)))) -> json.Json {
  deserialized
  |> json.array(object)
}

pub fn object(deserialized: List(#(String, String))) -> json.Json {
  {
    use it <- list.map(deserialized)
    #(it.0, it.1 |> json.string)
  }
  |> json.object()
}

// Loan serialization functions
pub fn loan_to_json_data(loan_item: loan.Loan) -> List(#(String, String)) {
  [
    #("id", loan.id_value(loan_item)),
    #("book_id", loan.book_id(loan_item) |> book_id.to_string),
    #("loan_date", loan.loan_date(loan_item)),
    #("due_date", loan.due_date(loan_item)),
  ]
}

pub fn loans_to_json_data(
  loans: List(loan.Loan),
) -> List(List(#(String, String))) {
  loans
  |> list.map(loan_to_json_data)
}
