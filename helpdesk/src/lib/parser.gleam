import gleam/option.{type Option, None, Some}
import gleam/result

pub fn map_or(
  option: Option(a),
  with: fn(a) -> Result(ok, ng),
) -> Result(Option(ok), ng) {
  case option {
    Some(x) -> with(x) |> result.map(Some)
    None -> None |> Ok()
  }
}
