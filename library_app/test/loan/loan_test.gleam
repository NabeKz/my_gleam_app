import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/result
import gleeunit
import gleeunit/should
import wisp/testing

import app/context
import core/auth/auth_provider
import core/book/domain/book
import core/book/domain/book_repository
import core/loan/domain/loan
import core/loan/domain/loan_repository
import core/shared/ports/schedule_repository
import core/shared/types/date
import core/shared/types/user
import shell/adapters/web/router

pub fn main() {
  gleeunit.main()
}

pub fn get_loans_success_test() {
  let req = testing.get("/api/loans?hoge=1", [])
  let assert Ok(book) = book.new("a", "b")
  let ctx = context.new()

  let repos =
    context.Repositories(
      book: context.mock_repositories().book,
      loan: loan_repository.LoanRepository(
        get_loans: fn(_) {
          [
            loan.new(
              book.id,
              user.id_from_string("1"),
              date.from(#(2025, 7, 31)),
              [],
            ),
            loan.new(
              book.id,
              user.id_from_string("2"),
              date.from(#(2025, 8, 1)),
              [],
            ),
            loan.new(
              book.id,
              user.id_from_string("3"),
              date.from(#(2025, 8, 30)),
              [],
            ),
          ]
          |> result.values()
        },
        get_loan: fn(_) { Error(["not implemented"]) },
        get_loan_by_id: fn(_) { Error(["not implemented"]) },
        save_loan: fn(_) { Ok(Nil) },
        put_loan: fn(_) { Ok(Nil) },
      ),
      schedule: context.mock_repositories().schedule,
    )

  let ops = context.create_operations(ctx, repos)
  let response = router.handle_request(req, ctx, ops)

  response.status
  |> should.equal(200)

  let assert Ok(response) =
    response
    |> testing.string_body()
    |> json.parse(decode.list(decode.dynamic))

  response
  |> list.length()
  |> should.equal(3)
}

pub fn create_loan_success_test() {
  let req =
    testing.post_json(
      "/api/books/a/loans",
      [#("authorization", "dummy")],
      json.object([]),
    )
  let assert Ok(book) = book.new("a", "b")
  let ctx =
    context.Context(..context.new(), authenticated: auth_provider.on_mock())

  let repos =
    context.Repositories(
      book: book_repository.BookRepository(
        search: fn(_) { [] },
        create: fn(_) { Ok(Nil) },
        read: fn(_) { Error(["not implemented"]) },
        update: fn(_) { Ok(Nil) },
        delete: fn(_) { Ok(Nil) },
        exists: fn(_) { Ok(book.id) },
      ),
      loan: loan_repository.LoanRepository(
        get_loans: fn(_) { [] },
        get_loan: fn(_) { Error(["not implemented"]) },
        get_loan_by_id: fn(_) { Error(["not implemented"]) },
        save_loan: fn(_) { Ok(Nil) },
        put_loan: fn(_) { Ok(Nil) },
      ),
      schedule: schedule_repository.ScheduleRepository(
        get_specify_schedules: fn(_) { [] },
      ),
    )

  let ops = context.create_operations(ctx, repos)
  let response = router.handle_request(req, ctx, ops)

  response.status
  |> should.equal(201)

  response
  |> testing.string_body()
  |> should.equal("")
}

pub fn create_loan_failure_test() {
  let req =
    testing.post_json(
      "/api/books/a/loans",
      [#("authorization", "dummy")],
      json.object([]),
    )
  let ctx = context.new()

  let repos =
    context.Repositories(
      book: book_repository.BookRepository(
        search: fn(_) { [] },
        create: fn(_) { Ok(Nil) },
        read: fn(_) { Error(["not implemented"]) },
        update: fn(_) { Ok(Nil) },
        delete: fn(_) { Ok(Nil) },
        exists: fn(_) { Error("not found") },
      ),
      loan: context.mock_repositories().loan,
      schedule: context.mock_repositories().schedule,
    )

  let ops = context.create_operations(ctx, repos)
  let response = router.handle_request(req, ctx, ops)

  response.status
  |> should.equal(400)

  response
  |> testing.string_body()
  |> should.equal("\"not found\"")
}

pub fn has_overdue_false_test() {
  let loan_date = date.from(#(2025, 7, 1))
  let current_date = date.from(#(2025, 7, 15))
  let assert Ok(loan) =
    loan.new(book.id_from_string("1"), user.id_from_string("a"), loan_date, [])

  loan.has_overdue([loan], current_date)
  |> should.be_false()
}

pub fn has_overdue_true_test() {
  let loan_date = date.from(#(2025, 7, 1))
  let current_date = date.from(#(2025, 7, 16))
  let assert Ok(loan) =
    loan.new(book.id_from_string("1"), user.id_from_string("a"), loan_date, [])

  loan.has_overdue([loan], current_date)
  |> should.be_true()
}

pub fn is_loan_limit_true_test() {
  let expect =
    list.repeat(
      loan.new(
        book.id_from_string("1"),
        user.id_from_string("a"),
        date.from(#(2025, 7, 16)),
        [],
      ),
      10,
    )
    |> result.values()

  expect
  |> loan.is_loan_limit()
  |> should.be_true()
}

pub fn is_loan_limit_false_test() {
  let expect =
    list.repeat(
      loan.new(
        book.id_from_string("1"),
        user.id_from_string("a"),
        date.from(#(2025, 7, 16)),
        [],
      ),
      9,
    )
    |> result.values()

  expect
  |> loan.is_loan_limit()
  |> should.be_false()
}
