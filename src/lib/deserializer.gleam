import gleam/json

pub fn deserialize_error(error_message: List(#(String, String))) -> json.Json {
  use error_message <- json.array(error_message)

  json.object([#("message", json.string(error_message.1))])
}
