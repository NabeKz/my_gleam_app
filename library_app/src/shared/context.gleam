import features/book/usecase

pub type Context {
  Context(search_books: usecase.SearchBooks)
}

pub fn new() -> Context {
  Context(search_books: usecase.search_books(_, fn() { [] }))
}
