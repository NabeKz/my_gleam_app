import core/auth/auth_provider
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
  let assert Ok(book) = book.new("a", "b")

  let ctx =
    context.Context(
      ..context.new(),
      authenticated: auth_provider.on_request(_, fn(_) { Ok(user) }),
      get_loans: fn(_) {
        [
          loan.new(book.id, user.id, date.from(#(2025, 7, 31)), []),
          loan.new(
            book.id,
            user.id_from_string("1"),
            date.from(#(2025, 7, 31)),
            [],
          ),
        ]
        |> result.values()
      },
      create_loan: fn(_, _) { Ok(Nil) },
    )
  let response = router.handle_request(req, ctx)

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
  let assert Ok(book) = book.new("a", "b")

  let ctx =
    context.Context(
      ..context.new(),
      authenticated: auth_provider.on_request(_, fn(_) { Ok(user) }),
      get_loans: fn(_) {
        [
          loan.new(book.id, user.id, date.from(#(2025, 7, 31)), []),
          loan.new(
            book.id,
            user.id_from_string("1"),
            date.from(#(2025, 7, 31)),
            [],
          ),
        ]
        |> result.values()
      },
      create_loan: fn(_, _) { Ok(Nil) },
    )
  let response = router.handle_request(req, ctx)

  response.status
  |> should.equal(401)

  response
  |> testing.string_body()
  |> should.equal("不正なフォーマットです")
}

pub fn post_loans_not_exits_authorization_failure_test() {
  let req = testing.post_json("/api/books/a_b_c/loans", [], json.object([]))
  let assert Ok(book) = book.new("a", "b")

  let ctx =
    context.Context(
      ..context.new(),
      authenticated: auth_provider.on_request(_, fn(_) { Ok(user.new()) }),
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
      create_loan: fn(_, _) { Ok(Nil) },
    )
  let response = router.handle_request(req, ctx)

  response.status
  |> should.equal(401)

  response
  |> testing.string_body()
  |> should.equal("トークンが見つかりません")
}
