import gleam/dynamic/decode
import gleam/option

pub fn required_field(
  name: String,
  decoder: decode.Decoder(a),
  next: fn(a) -> decode.Decoder(b),
) -> decode.Decoder(b) {
  decode.field(name, decoder, next)
}

pub fn optional_field(
  name: String,
  decoder: decode.Decoder(a),
  next: fn(option.Option(a)) -> decode.Decoder(b),
) -> decode.Decoder(b) {
  decode.optional_field(name, option.None, decoder |> decode.optional, next)
}
