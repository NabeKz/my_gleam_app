import gleam/erlang/atom

pub type Table {
  Table(name: atom.Atom)
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
// @external(erlang, "ets", "lookup")
// fn lookup(table: atom.Atom, key: k) -> List(#(k, v))

// pub fn get(table: Table, key: k) -> Result(#(k, v), String) {
//   case table.value |> lookup(key) {
//     [value] -> Ok(value)
//     _ -> Error("not found")
//   }
// }
// fn put(table: Table, tuple: #(k, v)) -> Nil {
//   table.value |> insert(tuple)
// }

// @external(erlang, "ets", "delete")
// fn delete_table(table: atom.Atom, key: k) -> Nil

// fn delete(table: Table, key: k) -> Nil {
//   table.value |> delete_table(key)
// }
