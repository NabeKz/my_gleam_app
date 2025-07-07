import codegen/atlas_types.{type AtlasSchema}
import gleam/erlang
import gleam/json
import gleam/list
import gleam/result
import gleam/string

pub fn read_all() -> Result(AtlasSchema, String) {
  use value <- result.try(read_all_stdin())

  generate_schema(value)
}

fn read_all_stdin() -> Result(String, String) {
  read_lines_recursive([])
}

fn read_lines_recursive(acc: List(String)) -> Result(String, String) {
  case erlang.get_line("") {
    Ok(line) -> {
      let trimmed = string.trim(line)
      case trimmed {
        "" -> Ok(string.join(acc, "\n"))
        _ -> read_lines_recursive([trimmed, ..acc])
      }
    }
    Error(_) -> {
      case acc {
        [] -> Error("No input received")
        _ -> Ok(string.join(acc |> list.reverse, "\n"))
      }
    }
  }
}

pub fn generate_schema(input: String) -> Result(AtlasSchema, String) {
  use schema <- result.try(json_to_schema(input))
  Ok(schema)
}

fn json_to_schema(json_input: String) {
  json.parse(json_input, atlas_types.atlas_schema_decoder())
  |> result.map_error(fn(err) { string.inspect(err) })
}
