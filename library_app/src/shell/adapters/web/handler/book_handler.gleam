import wisp

import app/context
import core/book/book
import core/book/book_command
import core/book/book_query
import shell/adapters/web/handler/helper/json

pub fn get(req: wisp.Request, ops: context.Operations) {
  use query <- json.get_query(req, book_query.generate_search_params)

  case ops.book.search(query) {
    Ok(books) -> {
      books
      |> json.array(decode)
      |> json.ok()
    }
    Error(_) -> {
      [#("message", "error" |> json.string)]
      |> json.object()
      |> json.bad_request()
    }
  }
}

fn decode(book: book.Book) -> json.Json {
  [
    #("id", book.id |> book.id_to_string() |> json.string()),
    #("title", book |> book.title_value |> json.string()),
    #("author", book |> book.author_value |> json.string()),
  ]
  |> json.object()
}

///
pub fn post(
  req: wisp.Request,
  ops: context.Operations,
) -> wisp.Response {
  use params <- json.get_body(req, book_command.decode_create_params)

  case ops.book.create(params) {
    Ok(_) -> wisp.created()
    Error(error) -> json.bad_request(error |> json.error)
  }
}

///
pub fn put(
  req: wisp.Request,
  book_id: String,
  ops: context.Operations,
) -> wisp.Response {
  use params <- json.get_body(req, book_command.decode_update_params)

  case ops.book.update(book_id, params) {
    Ok(_) -> wisp.ok()
    Error(error) -> json.bad_request(error |> json.error)
  }
}

///
pub fn delete(
  book_id: String,
  ops: context.Operations,
) -> wisp.Response {
  case ops.book.delete(book_id) {
    Ok(_) -> wisp.no_content()
    Error(error) -> json.bad_request(error |> json.error)
  }
}
