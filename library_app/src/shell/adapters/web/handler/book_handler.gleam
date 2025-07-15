import core/book/types/book_id
import gleam/json
import wisp

import core/book/services/converter
import core/book/types/book

pub fn get(req: wisp.Request, search_books: book.SearchBooks) {
  let result =
    req
    |> wisp.get_query()
    |> converter.to_search_params()
    |> search_books()

  case result {
    Ok(books) -> {
      books
      |> json.array(decode)
      |> json.to_string_tree()
      |> wisp.json_response(200)
    }
    Error(_) -> {
      "error"
      |> json.string()
      |> json.to_string_tree()
      |> wisp.json_response(400)
    }
  }
}

fn decode(book: book.Book) -> json.Json {
  [
    #("id", book.id |> book_id.to_string() |> json.string()),
    #("title", book |> book.title_value |> json.string()),
    #("author", book |> book.author_value |> json.string()),
  ]
  |> json.object()
}
