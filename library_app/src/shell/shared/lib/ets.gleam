import gleam/erlang/atom
import gleam/list

pub type Conn(k, v) {
  Conn(
    all: fn() -> List(v),
    get: fn(k) -> Result(v, String),
    create: fn(#(k, v)) -> Result(Nil, String),
    update: fn(#(k, v)) -> Result(Nil, List(String)),
    delete: fn(k) -> Result(Nil, String),
  )
}

pub type All(v) =
  fn() -> List(v)

pub type Tid

type Table {
  Table(value: Tid)
}

pub fn conn(items: List(a), key: fn(a) -> b) -> Conn(b, a) {
  let table = init("ets")
  {
    use it <- list.each(items)
    update(table, #(key(it), it))
  }

  Conn(
    all: fn() { table |> all },
    get: get(table, _),
    create: create(table, _),
    update: update(table, _),
    delete: delete(table, _),
  )
}

// === ETS FFI ===
@external(erlang, "ets", "new")
fn new(name: atom.Atom, props: List(atom.Atom)) -> Tid

fn init(name: String) -> Table {
  atom.create(name)
  |> new([atom.create("ordered_set"), atom.create("public")])
  |> Table()
}

@external(erlang, "ets", "tab2list")
fn tab2list(name: Tid) -> List(#(k, v))

fn all(table: Table) -> List(v) {
  let table = table.value |> tab2list
  use it <- list.map(table)
  it.1
}

@external(erlang, "ets", "lookup")
fn lookup(table: Tid, key: k) -> List(#(k, v))

fn get(table: Table, key: k) -> Result(v, String) {
  case table.value |> lookup(key) {
    [value] -> Ok(value.1)
    _ -> Error("not found")
  }
}

@external(erlang, "ets", "insert_new")
fn insert_new(name: Tid, tuple: #(k, v)) -> Bool

fn create(table: Table, item: #(k, v)) -> Result(Nil, String) {
  case table.value |> insert_new(item) {
    True -> Ok(Nil)
    False -> Error("already exists")
  }
}

@external(erlang, "ets", "insert")
fn insert(name: Tid, tuple: #(k, v)) -> Nil

fn update(table: Table, tuple: #(k, v)) -> Result(Nil, List(String)) {
  table.value
  |> insert(tuple)
  |> Ok()
}

@external(erlang, "ets", "delete")
fn delete_table(table: Tid, key: k) -> Nil

fn delete(table: Table, key: k) -> Result(Nil, String) {
  table.value |> delete_table(key) |> Ok()
}
