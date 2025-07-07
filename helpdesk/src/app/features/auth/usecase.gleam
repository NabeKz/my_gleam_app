import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/result

type Dto {
  Dto(id: String, password: String)
}

pub fn invoke(values: List(#(String, String))) {
  echo values
  let json = values |> dict.from_list |> dynamic.from
  let result = {
    use dto <- result.try(decode.run(json, decode_ticket()))
    dto |> Ok()
  }

  case result {
    Ok(values) -> validate(values)
    Error(_) -> False
  }
}

fn decode_ticket() -> decode.Decoder(Dto) {
  use id <- decode.field("id", decode.string)
  use password <- decode.field("password", decode.string)
  decode.success(Dto(id:, password:))
}

fn validate(dto: Dto) -> Bool {
  case dto.id, dto.password {
    "test", "test@example.com" -> True
    _, _ -> False
  }
}
