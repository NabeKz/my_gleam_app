import gleam/option

pub type SearchParams {
  SearchParams(title: option.Option(String), author: option.Option(String))
}

pub type UnValidatedBook {
  UnValidatedBook(title: option.Option(String), author: option.Option(String))
}
