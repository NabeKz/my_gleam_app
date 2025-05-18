import gleam/bit_array
import gleam/result
import gleam/uri
import wisp

pub type Request =
  wisp.Request

pub type Response =
  wisp.Response

pub type Security =
  wisp.Security

pub type FormData =
  wisp.FormData

/// request handler
pub const path_segments = wisp.path_segments

pub const require_method = wisp.require_method

pub const method_not_allowed = wisp.method_not_allowed

pub const get_query = wisp.get_query

pub fn require_form(req: Request) -> FormData {
  let values =
    wisp.read_body_to_bitstring(req)
    |> result.map(bit_array.to_string)
    |> result.flatten()
    |> result.map(uri.parse_query)
    |> result.flatten()
    |> result.unwrap([])
  wisp.FormData(values:, files: [])
}

pub const require_json = wisp.require_json

pub const handle_head = wisp.handle_head

// response
pub const html_response = wisp.html_response

pub const json_response = wisp.json_response

// http error
pub const bad_request = wisp.bad_request

pub const unprocessable_entity = wisp.unprocessable_entity

pub const not_found = wisp.not_found

pub const method_override = wisp.method_override

pub const internal_server_error = wisp.internal_server_error

pub fn get_cookie_with_plan_text(req: Request, name: String) {
  wisp.get_cookie(req, name, wisp.PlainText)
}

pub fn get_cookie_with_signed(req: Request, name: String) {
  wisp.get_cookie(req, name, wisp.Signed)
}
