import gleam/json
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
import core/shared/types/date
import core/shared/types/user
import shell/adapters/web/router

pub fn main() {
  gleeunit.main()
}

pub fn post_loans_success_test() {
  let user = user.new()
  let assert Ok(book) = book.new("a", "b")

  let ctx =
    context.Context(
      ..context.new(),
      authenticated: auth_provider.on_request(_, fn(_) { Ok(user) }),
    )

  let repos =
    context.Repositories(
      book: book_repository.BookRepository(
        ..context.mock_repositories().book,
        exists: fn(_) { Ok(book.id) },
      ),
      loan: loan_repository.LoanRepository(
        ..context.mock_repositories().loan,
        get_loans: fn(_) {
          [loan.new(book.id, user.id, date.from(#(2025, 7, 31)), [])]
          |> result.values()
        },
        save_loan: fn(_) { Ok(Nil) },
      ),
      schedule: context.mock_repositories().schedule,
    )
  let ops = context.create_operations(ctx, repos)

  let response =
    testing.post_json(
      "/api/books/" <> book.id_to_string(book.id) <> "/loans",
      [#("authorization", "Bearer hoge")],
      json.object([]),
    )
    |> router.handle_request(ctx, ops)

  response.status
  |> should.equal(201)
}

pub fn post_loans_not_bearer_failure_test() {
  let user = user.new()
  let req =
    testing.post_json(
      "/api/books/hoge-fuga/loans",
      [#("authorization", "hoge")],
      json.object([]),
    )
  let assert Ok(_test_book) = book.new("a", "b")

  let ctx =
    context.Context(
      ..context.new(),
      authenticated: auth_provider.on_request(_, fn(_) { Ok(user) }),
    )

  let repos = context.mock_repositories()
  let ops = context.create_operations(ctx, repos)
  let response = router.handle_request(req, ctx, ops)

  response.status
  |> should.equal(401)

  response
  |> testing.string_body()
  |> should.equal("不正なフォーマットです")
}

pub fn post_loans_not_exits_authorization_failure_test() {
  let req = testing.post_json("/api/books/a_b_c/loans", [], json.object([]))
  let assert Ok(_test_book) = book.new("a", "b")

  let ctx =
    context.Context(
      ..context.new(),
      authenticated: auth_provider.on_request(_, fn(_) { Ok(user.new()) }),
    )

  let repos = context.mock_repositories()
  let ops = context.create_operations(ctx, repos)
  let response = router.handle_request(req, ctx, ops)

  response.status
  |> should.equal(401)

  response
  |> testing.string_body()
  |> should.equal("トークンが見つかりません")
}
