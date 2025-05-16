import gleam/erlang/atom

pub type Conn(k, v) {
  Conn(
    all: fn() -> List(#(k, v)),
    get: fn(k) -> Result(#(k, v), String),
    put: fn(#(k, v)) -> String,
    delete: fn(k) -> Nil,
  )
}

@external(erlang, "ets", "new")
fn new(name: atom.Atom, props: List(atom.Atom)) -> Nil

pub fn init(name: String) -> String {
  atom.create_from_string(name)
  |> new([
    atom.create_from_string("set"),
    atom.create_from_string("named_table"),
  ])
  name
}

@external(erlang, "ets", "select")
fn all_private(name: atom.Atom, params: List(#(k, v))) -> List(#(k, v))

pub fn all(name: String) -> List(#(k, v)) {
  atom.create_from_string(name)
  |> all_private([])
}

@external(erlang, "ets", "insert")
fn insert(name: atom.Atom, tuple: #(k, v)) -> Nil

pub fn put(name: String, tuple: #(k, v)) -> String {
  name
  |> atom.create_from_string()
  |> insert(tuple)
  name
}

@external(erlang, "ets", "lookup")
fn lookup(table: atom.Atom, key: k) -> List(#(k, v))

pub fn get(table: String, key: k) -> Result(#(k, v), String) {
  let result =
    table
    |> atom.create_from_string()
    |> lookup(key)

  case result {
    [value] -> Ok(value)
    _ -> Error("not found")
  }
}

@external(erlang, "ets", "delete")
fn delete_table(table: atom.Atom, key: k) -> Nil

pub fn delete(table: String, key: k) -> Nil {
  table
  |> atom.create_from_string()
  |> delete_table(key)
}

pub fn conn(name: String) -> Conn(k, v) {
  init(name)
  Conn(
    all: fn() { name |> all() },
    get: get(name, _),
    put: put(name, _),
    delete: delete(name, _),
  )
}
