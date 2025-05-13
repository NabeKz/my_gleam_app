import gleam/dynamic
import gleam/erlang/atom

@external(erlang, "ets", "new")
fn new_ets(name: atom.Atom, props: List(dynamic.Dynamic)) -> Nil

pub fn new(name: String) -> Nil {
  atom.create_from_string(name)
  |> new_ets([])
}

@external(erlang, "ets", "all")
pub fn all() -> Nil
