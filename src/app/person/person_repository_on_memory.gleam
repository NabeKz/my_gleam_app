import app/person/person.{
  type Person, type PersonReadModel, Person, PersonReadModel,
}
import gleam/int
import gleam/list

pub fn new() -> person.PersonRepository {
  let items = [
    PersonReadModel(id: "1", name: "hoge", favorite_color: "#FFF"),
    PersonReadModel(id: "2", name: "fuga", favorite_color: "#999"),
    PersonReadModel(id: "3", name: "piyo", favorite_color: "#000"),
  ]

  person.PersonRepository(
    all: fn() { Ok(items) },
    save: fn(item: Person) { save(items, item) },
    read: fn(id: String) { read(items, id) },
    delete: fn(id: String) { delete(items, id) },
  )
}

fn save(items: List(PersonReadModel), item: Person) -> Result(String, _) {
  let id = list.length(of: items) |> int.to_string()

  PersonReadModel(id: id, name: item.name, favorite_color: item.favorite_color)
  |> list.wrap()
  |> list.append(items, _)

  Ok(id)
}

fn read(
  items: List(PersonReadModel),
  id: String,
) -> Result(PersonReadModel, List(String)) {
  let result = items |> list.find(fn(item) { item.id == id })
  case result {
    Ok(item) -> Ok(item)
    Error(Nil) -> Error(["not found"])
  }
}

fn delete(
  items: List(PersonReadModel),
  id: String,
) -> Result(List(PersonReadModel), List(String)) {
  let result = items |> list.find(fn(item) { item.id == id })
  case result {
    Ok(_) -> Ok(list.filter(items, fn(item) { item.id == id }))
    Error(_) -> Error(["not found"])
  }
}
