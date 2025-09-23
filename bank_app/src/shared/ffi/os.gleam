import gleam/erlang/charlist.{type Charlist}
import gleam/result

@external(erlang, "file", "get_cwd")
fn get_cwd_ffi() -> Result(Charlist, String)

pub fn get_cwd() -> Result(String, String) {
  get_cwd_ffi()
  |> result.map(charlist.to_string)
}
