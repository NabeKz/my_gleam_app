import core/auth/auth_provider
import core/loan/ports/loan_repository
import core/shared/types/user
import gleam/json
import gleam/result
import gleeunit
import gleeunit/should
import wisp/testing

import app/context
import core/book/book
import core/loan/loan
import core/shared/types/date
import shell/adapters/web/router

pub fn main() {
  gleeunit.main()
}

pub fn post_loans_success_test() {
  let user = user.new()
  let req =
    testing.post_json(
      "/api/books/hoge-fuga/loans",
      [#("authorization", "Bearer hoge")],
      json.object([]),
    )
  let assert Ok(test_book) = book.new("a", "b")

  let ctx =
    context.Context(
      ..context.new(),
      authenticated: auth_provider.on_request(_, fn(_) { Ok(user) }),
    )
  
  let repos = context.Repositories(
    book: context.mock_repositories().book,
    loan: loan_repository.LoanRepository(
      get_loans: fn(_) {
        [
          loan.new(test_book.id, user.id, date.from(#(2025, 7, 31)), []),
          loan.new(
            test_book.id,
            user.id_from_string("1"),
            date.from(#(2025, 7, 31)),
            [],
          ),
        ]
        |> result.values()
      },
      get_loan: fn(_) { Error("not implemented") },
      get_loan_by_id: fn(_) { Error("not implemented") },
      save_loan: fn(_) { Ok(Nil) },
      put_loan: fn(_) { Ok(Nil) },
    ),
    schedule: context.mock_repositories().schedule,
  )
  
  let ops = context.create_operations(ctx, repos)
  let response = router.handle_request(req, ctx, ops)

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
