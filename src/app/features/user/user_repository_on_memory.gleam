import gleam/int
import gleam/list

import app/features/user/user.{type User, type UserReadModel, UserReadModel}

pub fn new() -> user.UserRepository {
  let items = [
    UserReadModel(id: "1", name: "hoge", favorite_color: "#FFF"),
    UserReadModel(id: "2", name: "fuga", favorite_color: "#999"),
    UserReadModel(id: "3", name: "piyo", favorite_color: "#000"),
  ]

  user.UserRepository(
    listed: fn() { Ok(items) },
    save: fn(item: User) { save(items, item) },
    read: fn(id: String) { read(items, id) },
    delete: fn(id: String) { delete(items, id) },
  )
}

fn save(items: List(UserReadModel), _item: User) -> Result(String, _) {
  let id = list.length(of: items) |> int.to_string()

  Ok(id)
}

fn read(
  items: List(UserReadModel),
  id: String,
) -> Result(UserReadModel, List(String)) {
  let result = list.find(items, fn(item) { item.id == id })

  case result {
    Ok(item) -> Ok(item)
    Error(_) -> Error(["not found"])
  }
}

fn delete(
  items: List(UserReadModel),
  id: String,
) -> Result(List(UserReadModel), List(String)) {
  let result = items |> list.find(fn(item) { item.id == id })
  case result {
    Ok(_) -> Ok(list.filter(items, fn(item) { item.id == id }))
    Error(_) -> Error(["not found"])
  }
}
