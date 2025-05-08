import gleam/int
import gleam/list
import gleam/option

import app/features/user/user.{
  type Person, type PersonReadModel, PersonReadModel,
}

pub fn new() -> user.PersonRepository {
  let items = [
    PersonReadModel(id: "1", name: "hoge", favorite_color: option.Some("#FFF")),
    PersonReadModel(id: "2", name: "fuga", favorite_color: option.Some("#999")),
    PersonReadModel(id: "3", name: "piyo", favorite_color: option.Some("#000")),
  ]

  user.PersonRepository(
    all: fn() { Ok(items) },
    save: fn(item: Person) { save(items, item) },
    read: fn(id: String) { read(items, id) },
    delete: fn(id: String) { delete(items, id) },
  )
}

fn save(items: List(PersonReadModel), item: Person) -> Result(String, _) {
  let id = list.length(of: items) |> int.to_string()
  let favorite_color = case item {
    user.Guest(_) -> option.None
    user.Member(_, favorite_color) -> option.Some(favorite_color)
    user.Admin(_, favorite_color) -> option.Some(favorite_color)
  }
  PersonReadModel(id: id, name: item.name, favorite_color:)
  |> list.wrap()
  |> list.append(items, _)

  Ok(id)
}

fn read(
  items: List(PersonReadModel),
  id: String,
) -> Result(PersonReadModel, List(String)) {
  let result = list.find(items, fn(item) { item.id == id })

  case result {
    Ok(item) -> Ok(item)
    Error(_) -> Error(["not found"])
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
