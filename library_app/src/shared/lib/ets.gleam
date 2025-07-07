import gleam/erlang/atom
import gleam/list

pub type Conn(k, v) {
  Conn(
    all: fn() -> List(v),
    get: fn(k) -> Result(#(k, v), String),
    create: fn(#(k, v)) -> k,
    put: fn(#(k, v)) -> Nil,
    delete: fn(k) -> Nil,
  )
}

pub type MatchSpec

pub type Table {
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

pub fn init(name: String) -> Table {
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

pub fn all(table: Table) -> List(v) {
  let table = table.value |> tab2list
  use it <- list.map(table)
  it.1
}

@external(erlang, "ets", "lookup")
fn lookup(table: atom.Atom, key: k) -> List(#(k, v))

fn get(table: Table, key: k) -> Result(#(k, v), String) {
  case table.value |> lookup(key) {
    [value] -> Ok(value)
    _ -> Error("not found")
  }
}

@external(erlang, "ets", "insert")
fn insert(name: atom.Atom, tuple: #(k, v)) -> Nil

fn create(table: Table, item: #(k, v)) -> k {
  table.value |> insert(item)
  item.0
}

fn put(table: Table, tuple: #(k, v)) -> Nil {
  table.value |> insert(tuple)
}

@external(erlang, "ets", "delete")
fn delete_table(table: atom.Atom, key: k) -> Nil

fn delete(table: Table, key: k) -> Nil {
  table.value |> delete_table(key)
}
