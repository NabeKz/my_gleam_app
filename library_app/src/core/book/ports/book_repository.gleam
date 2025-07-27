import core/book/book
import core/book/book_ports

pub type BookRepository {
  BookRepository(
    search: fn(book_ports.SearchParams) -> List(book.Book),
    create: fn(book.Book) -> Result(Nil, List(String)),
    read: fn(String) -> Result(book.Book, List(String)),
    update: fn(book.Book) -> Result(Nil, List(String)),
    delete: fn(String) -> Result(Nil, List(String)),
    exists: fn(String) -> Result(book.BookId, String),
  )
}
