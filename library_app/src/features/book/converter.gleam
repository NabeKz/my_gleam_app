import gleam/dynamic
import gleam/dynamic/decode
import gleam/list

import features/book/domain

pub fn to_search_params(
  query: List(#(String, String)),
) -> Result(domain.SearchParams, List(decode.DecodeError)) {
  let query = {
    use it <- list.map(query)
    #(it.0 |> dynamic.string, it.1 |> dynamic.string)
  }
  let decoder = {
    use title <- decode.field("title", decode.string |> decode.optional)
    use author <- decode.field("author", decode.string |> decode.optional)
    decode.success(domain.SearchParams(title:, author:))
  }

  decode.run(query |> dynamic.properties, decoder)
}
