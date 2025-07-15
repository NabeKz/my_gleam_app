import wisp

import core/book/book
import core/book/book_ports
import core/book/book_query
import shell/adapters/web/handler/helper/json

pub fn get(req: wisp.Request, search_books: book_ports.GetBooksWorkflow) {
  use query <- json.get_query(req, book_query.generate_search_params)

  case search_books(query) {
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
