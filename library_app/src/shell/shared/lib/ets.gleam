import gleam/erlang/atom
import gleam/list

pub type Conn(k, v) {
  Conn(
    all: fn() -> List(v),
    get: fn(k) -> Result(v, String),
    create: fn(#(k, v)) -> Result(Nil, String),
    put: fn(#(k, v)) -> Nil,
    delete: fn(k) -> Nil,
  )
}

pub type All(v) =
  fn() -> List(v)

pub type MatchSpec

type Table {
  Table(value: atom.Atom)
}

pub fn conn(name: String, items: List(a), key: fn(a) -> b) -> Conn(b, a) {
  let table = init(name)
  {
    use it <- list.each(items)
    put(table, #(key(it), it))
  }

  Conn(
    all: fn() { table |> all },
    get: get(table, _),
    create: create(table, _),
    put: put(table, _),
    delete: delete(table, _),
  )
}

// === ETS FFI ===
@external(erlang, "ets", "new")
fn new(name: atom.Atom, props: List(atom.Atom)) -> Nil

fn init(name: String) -> Table {
  let name = atom.create(name)
  name
  |> new([
    atom.create("ordered_set"),
    atom.create("named_table"),
    atom.create("public"),
  ])
  Table(name)
}

@external(erlang, "ets", "tab2list")
fn tab2list(name: atom.Atom) -> List(#(k, v))

fn all(table: Table) -> List(v) {
  let table = table.value |> tab2list
  use it <- list.map(table)
  it.1
}

@external(erlang, "ets", "lookup")
fn lookup(table: atom.Atom, key: k) -> List(#(k, v))

fn get(table: Table, key: k) -> Result(v, String) {
  case table.value |> lookup(key) {
    [value] -> Ok(value.1)
    _ -> Error("not found")
  }
}

@external(erlang, "ets", "insert_new")
fn insert_new(name: atom.Atom, tuple: #(k, v)) -> Bool

fn create(table: Table, item: #(k, v)) -> Result(Nil, String) {
  case table.value |> insert_new(item) {
    True -> Ok(Nil)
    False -> Error("already exists")
  }
}

@external(erlang, "ets", "insert")
fn insert(name: atom.Atom, tuple: #(k, v)) -> Nil

fn put(table: Table, tuple: #(k, v)) -> Nil {
  table.value |> insert(tuple)
}

@external(erlang, "ets", "delete")
fn delete_table(table: atom.Atom, key: k) -> Nil

fn delete(table: Table, key: k) -> Nil {
  table.value |> delete_table(key)
}
