import gleam/erlang/atom

@external(erlang, "ets", "new")
fn new(name: atom.Atom, props: List(atom.Atom)) -> Nil

pub fn init(name: String) -> Nil {
  atom.create_from_string(name)
  |> new([
    atom.create_from_string("set"),
    atom.create_from_string("named_table"),
  ])
}

@external(erlang, "ets", "insert")
fn insert(name: atom.Atom, tuple: #(k, v)) -> Nil

pub fn put(name: String, tuple: #(k, v)) -> Nil {
  name
  |> atom.create_from_string()
  |> insert(tuple)
}

@external(erlang, "ets", "lookup")
fn lookup(table: atom.Atom, key: k) -> List(#(k, v))

pub fn get(table: String, key: k) -> List(#(k, v)) {
  table
  |> atom.create_from_string()
  |> lookup(key)
}

@external(erlang, "ets", "delete")
fn delete_table(table: atom.Atom, key: k) -> Nil

pub fn delete(table: String, key: k) -> Nil {
  table
  |> atom.create_from_string()
  |> delete_table(key)
}
