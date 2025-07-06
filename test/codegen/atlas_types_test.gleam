import codegen/atlas_types
import codegen/stdin_reader
import gleam/json
import gleam/list
import gleam/option
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn atlas_schema_decode_test() {
  // 実際のAtlas JSONの例
  let json_input =
    "{
    \"schemas\": [{
      \"name\": \"main\",
      \"tables\": [{
        \"name\": \"tickets\",
        \"columns\": [
          {\"name\": \"id\", \"type\": \"INTEGER\", \"null\": true},
          {\"name\": \"title\", \"type\": \"TEXT\"},
          {\"name\": \"description\", \"type\": \"TEXT\"},
          {\"name\": \"status\", \"type\": \"TEXT\"},
          {\"name\": \"created_at\", \"type\": \"TEXT\"}
        ],
        \"primary_key\": {
          \"parts\": [{\"column\": \"id\"}]
        }
      }]
    }]
  }"

  let assert Ok(schema) = stdin_reader.generate_schema(json_input)
  let assert Ok(main_schema) = list.first(schema.schemas)
  main_schema.name |> should.equal("main")

  let assert Ok(tickets_table) = main_schema.tables |> list.first
  tickets_table.name |> should.equal("tickets")
  // // ID列の検証
  let id_column = case tickets_table.columns {
    [first, ..] -> first
    [] -> panic as "Should have columns"
  }
  id_column.name |> should.equal("id")
  id_column.type_ |> should.equal("INTEGER")
  id_column.null |> should.equal(option.Some(True))
  // // title列の検証
  let assert Ok(title_column) =
    list.find(tickets_table.columns, fn(it) { it.name == "title" })
  title_column.name |> should.equal("title")
  title_column.type_ |> should.equal("TEXT")
  title_column.null |> should.equal(option.None)
}

pub fn invalid_json_test() {
  let invalid_json = "{invalid json"

  // 無効なJSONは dynamic.from でエラーになる
  let result = json.parse(invalid_json, atlas_types.atlas_schema_decoder())
  should.be_error(result)
}
