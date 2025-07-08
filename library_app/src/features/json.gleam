import gleam/dynamic/decode
import gleam/json

pub type Json {
  Json(value: String)
}

pub type JsonDecoder(t, u) =
  fn(Json) -> Result(t, u)

pub fn to_json(body: String) -> Json {
  Json(body)
}

pub fn parse(
  json: Json,
  decoder: decode.Decoder(t),
) -> Result(t, json.DecodeError) {
  json.parse(json.value, decoder)
}
