import shared/lib/uuid
import shared/validator

pub type Book {
  Book(id: BookId, title: BookTitle, author: BookAuthor)
}

pub opaque type BookId {
  BookId(value: String)
}

pub opaque type BookTitle {
  BookTitle(value: String)
}

pub opaque type BookAuthor {
  BookAuthor(value: String)
}

pub fn id_to_string(vo: BookId) -> String {
  vo.value
}

pub fn title_to_string(vo: BookTitle) -> String {
  vo.value
}

pub fn new(
  title: String,
  author: String,
) -> Result(Book, List(validator.ValidateError)) {
  let validated = {
    use title <- validator.field(validate_title(title))
    use author <- validator.field(validate_author(author))

    Book(id: new_id(), title:, author:)
    |> validator.success()
  }
  validator.run(validated)
}

pub fn new_id() {
  BookId(uuid.v4())
}

fn validate_title(title: String) -> validator.Validator(BookTitle) {
  validator.wrap("title", title)
  |> validator.required_string()
  |> validator.less_than(200)
  |> validator.map(BookTitle)
}

fn validate_author(value: String) -> validator.Validator(BookAuthor) {
  validator.wrap("author", value)
  |> validator.required_string()
  |> validator.less_than(200)
  |> validator.map(BookAuthor)
}
