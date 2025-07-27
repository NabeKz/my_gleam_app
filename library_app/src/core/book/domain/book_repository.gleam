import core/book/domain/book

pub type BookRepository {
  BookRepository(
    search: book.GetBooks,
    create: book.CreateBook,
    read: book.GetBook,
    update: book.UpdateBook,
    delete: book.DeleteBook,
    exists: book.CheckBookExists,
  )
}
