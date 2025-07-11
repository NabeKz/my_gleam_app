import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import gleam/option

import features/book/domain

pub fn to_search_params(
  query: List(#(String, String)),
) -> Result(domain.SearchParams, List(decode.DecodeError)) {
  let query = {
    use it <- list.map(query)
    #(it.0 |> dynamic.string, it.1 |> dynamic.string)
  }
  let decoder = {
    use title <- decode.optional_field(
      "title",
      option.None,
      decode.string |> decode.optional,
    )
    use author <- decode.optional_field(
      "author",
      option.None,
      decode.string |> decode.optional,
    )

    decode.success(domain.SearchParams(title:, author:))
  }

  decode.run(query |> dynamic.properties, decoder)
}
