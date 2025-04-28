import gleam/json

pub fn deserialize_error(error_message: List(#(String, String))) -> json.Json {
  json.array(error_message, fn(error_message) {
    json.object([#("message", json.string(error_message.1))])
  })
}
