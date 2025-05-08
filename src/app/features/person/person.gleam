import gleam/option

pub type Person {
  Guest(name: String)
  Member(name: String, favorite_color: String)
  Admin(name: String, favorite_color: String)
}

pub type PersonReadModel {
  PersonReadModel(
    id: String,
    name: String,
    favorite_color: option.Option(String),
  )
}

pub type All =
  fn() -> Result(List(PersonReadModel), List(String))

pub type Save =
  fn(Person) -> Result(String, List(String))

pub type Read =
  fn(String) -> Result(PersonReadModel, List(String))

pub type Delete =
  fn(String) -> Result(List(PersonReadModel), List(String))

pub type PersonRepository {
  PersonRepository(all: All, save: Save, read: Read, delete: Delete)
}
