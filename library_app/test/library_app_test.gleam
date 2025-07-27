import app/context
import gleeunit
import gleeunit/should
import shell/adapters/web/router
import wisp/testing

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn books_optional_query_test() {
  let req = testing.get("/api/books?hoge=fuga&aaa=1", [])
  let ctx = context.new()
  let repos = context.mock_repositories()
  let ops = context.create_operations(ctx, repos)
  let response = router.handle_request(req, ctx, ops)

  response.status
  |> should.equal(200)
}
