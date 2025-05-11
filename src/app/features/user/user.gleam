pub type Guest {
  Guest(name: String)
}

pub type User {
  Member(name: String, favorite_color: String)
  Admin(name: String, favorite_color: String)
}

pub type UserReadModel {
  UserReadModel(id: UserId, name: String, favorite_color: String)
}

pub type UserId =
  String

pub type Listed =
  fn() -> Result(List(UserReadModel), List(String))

pub type Save =
  fn(User) -> Result(String, List(String))

pub type Read =
  fn(String) -> Result(UserReadModel, List(String))

pub type Delete =
  fn(String) -> Result(List(UserReadModel), List(String))

pub type UserRepository {
  UserRepository(listed: Listed, save: Save, read: Read, delete: Delete)
}

pub fn user_read_model_from_user(id: String, user: User) {
  UserReadModel(id: id, name: user.name, favorite_color: user.favorite_color)
}
