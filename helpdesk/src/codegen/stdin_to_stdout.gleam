import codegen/atlas_types.{type AtlasSchema, type Column, type Table}
import codegen/stdin_reader
import gleam/io
import gleam/list
import gleam/option
import gleam/string

pub fn main() {
  case stdin_reader.read_all() {
    Error(err) -> {
      io.println("Error reading stdin: " <> err)
    }
    Ok(input) -> {
      // JSON解析してtype-safeコード生成
      let generated_code = process_atlas_json(input)
      io.println(generated_code)
    }
  }
}

fn process_atlas_json(atlas_schema: AtlasSchema) -> String {
  let assert Ok(schema) = {
    use schema <- list.find(atlas_schema.schemas)
    schema.name == "main"
  }

  generate_all_code(schema.tables)
}

fn generate_all_code(tables: List(Table)) -> String {
  let tables = {
    use table <- list.filter(tables)
    table.name != "atlas_schema_revisions" && table.name != "sqlite_sequence"
  }
  let type_code = generate_types_code(tables)
  let crud_code = generate_crud_code(tables)

  "// Generated from Atlas schema (management tables excluded)\n"
  <> "import gleam/dynamic/decode\n"
  <> "import gleam/option.{type Option}\n"
  <> "import gleam/int\n"
  <> "import gleam/string\n"
  <> "import gleam/list\n\n"
  <> "// === TYPE DEFINITIONS ===\n\n"
  <> type_code
  <> "\n\n// === CRUD FUNCTIONS ===\n\n"
  <> crud_code
}

fn generate_types_code(tables: List(Table)) -> String {
  tables
  |> list.map(generate_table_types)
  |> string.join("\n\n")
}

fn generate_table_types(table: Table) -> String {
  let type_name = string_to_pascal_case(table.name)
  let type_def = generate_type_definition(type_name, table.columns)
  let decoder = generate_decoder(type_name, table.columns)

  type_def <> "\n\n" <> decoder
}

fn generate_type_definition(type_name: String, columns: List(Column)) -> String {
  let fields =
    list.map(columns, fn(col) {
      let field_name = col.name
      let gleam_type = sql_type_to_gleam_type(col.type_, col.null)
      "  " <> field_name <> ": " <> gleam_type
    })

  "pub type "
  <> type_name
  <> " {\n"
  <> "  "
  <> type_name
  <> "(\n"
  <> string.join(fields, ",\n")
  <> "\n  )\n}"
}

fn generate_decoder(type_name: String, columns: List(Column)) -> String {
  let decoder_name = string.lowercase(type_name) <> "_decoder"

  let field_decoders =
    list.index_map(columns, fn(col, idx) {
      let decoder_func = sql_type_to_decoder(col.type_)
      let final_decoder = case option.unwrap(col.null, False) {
        True -> "decode.optional(" <> decoder_func <> ")"
        False -> decoder_func
      }
      "  use "
      <> col.name
      <> " <- decode.field("
      <> string.inspect(idx)
      <> ", "
      <> final_decoder
      <> ")"
    })

  let constructor_fields =
    list.map(columns, fn(col) { col.name <> ": " <> col.name })

  "pub fn "
  <> decoder_name
  <> "() -> decode.Decoder("
  <> type_name
  <> ") {\n"
  <> string.join(field_decoders, "\n")
  <> "\n\n  decode.success("
  <> type_name
  <> "("
  <> string.join(constructor_fields, ", ")
  <> "))\n}"
}

fn generate_crud_code(tables: List(Table)) -> String {
  tables
  |> list.map(generate_table_crud)
  |> string.join("\n\n")
}

fn generate_table_crud(table: Table) -> String {
  let create_fn = generate_create_function(table.name, table.columns)
  let update_fn = generate_update_function(table.name, table.columns)
  let delete_fn = generate_delete_function(table.name)

  create_fn <> "\n\n" <> update_fn <> "\n\n" <> delete_fn
}

fn generate_create_function(table_name: String, columns: List(Column)) -> String {
  let insert_columns = list.filter(columns, fn(col) { col.name != "id" })
  let column_names = list.map(insert_columns, fn(col) { col.name })
  let placeholders = list.map(insert_columns, fn(_) { "?" })

  let function_name = "insert_" <> table_name
  let param_type = string_to_pascal_case(table_name) <> "Insert"

  let param_type_def = generate_insert_type(param_type, insert_columns)

  let function_def =
    "pub fn "
    <> function_name
    <> "(data: "
    <> param_type
    <> ") -> String {\n"
    <> "  \"INSERT INTO "
    <> table_name
    <> " ("
    <> string.join(column_names, ", ")
    <> ")\"\n"
    <> "  <> \" VALUES ("
    <> string.join(placeholders, ", ")
    <> ")\"\n"
    <> "}\n\n"
    <> "pub fn "
    <> function_name
    <> "_values(data: "
    <> param_type
    <> ") -> List(String) {\n"
    <> "  ["
    <> generate_value_extraction(insert_columns)
    <> "]\n"
    <> "}"

  param_type_def <> "\n\n" <> function_def
}

fn generate_update_function(table_name: String, columns: List(Column)) -> String {
  let update_columns = list.filter(columns, fn(col) { col.name != "id" })
  let set_clauses = list.map(update_columns, fn(col) { col.name <> " = ?" })

  let function_name = "update_" <> table_name
  let param_type = string_to_pascal_case(table_name) <> "Update"

  let param_type_def = generate_update_type(param_type, update_columns)

  let function_def =
    "pub fn "
    <> function_name
    <> "(id: Int, data: "
    <> param_type
    <> ") -> String {\n"
    <> "  \"UPDATE "
    <> table_name
    <> " SET "
    <> string.join(set_clauses, ", ")
    <> "\"\n"
    <> "  <> \" WHERE id = ?\"\n"
    <> "}\n\n"
    <> "pub fn "
    <> function_name
    <> "_values(id: Int, data: "
    <> param_type
    <> ") -> List(String) {\n"
    <> "  ["
    <> generate_value_extraction(update_columns)
    <> ", int.to_string(id)]\n"
    <> "}"

  param_type_def <> "\n\n" <> function_def
}

fn generate_delete_function(table_name: String) -> String {
  let function_name = "delete_" <> table_name

  "pub fn "
  <> function_name
  <> "(id: Int) -> String {\n"
  <> "  \"DELETE FROM "
  <> table_name
  <> " WHERE id = ?\"\n"
  <> "}\n\n"
  <> "pub fn "
  <> function_name
  <> "_values(id: Int) -> List(String) {\n"
  <> "  [int.to_string(id)]\n"
  <> "}"
}

fn generate_insert_type(type_name: String, columns: List(Column)) -> String {
  let fields =
    list.map(columns, fn(col) {
      let field_name = col.name
      let gleam_type = sql_type_to_gleam_type(col.type_, col.null)
      "  " <> field_name <> ": " <> gleam_type
    })

  "pub type "
  <> type_name
  <> " {\n"
  <> "  "
  <> type_name
  <> "(\n"
  <> string.join(fields, ",\n")
  <> "\n  )\n}"
}

fn generate_update_type(type_name: String, columns: List(Column)) -> String {
  let fields =
    list.map(columns, fn(col) {
      let field_name = col.name
      let gleam_type = sql_type_to_gleam_type(col.type_, col.null)
      "  " <> field_name <> ": " <> gleam_type
    })

  "pub type "
  <> type_name
  <> " {\n"
  <> "  "
  <> type_name
  <> "(\n"
  <> string.join(fields, ",\n")
  <> "\n  )\n}"
}

fn generate_value_extraction(columns: List(Column)) -> String {
  let value_extractions =
    list.map(columns, fn(col) {
      case option.unwrap(col.null, False) {
        True -> "option.unwrap(data." <> col.name <> ", \"\")"
        False ->
          case col.type_ {
            "INTEGER" -> "int.to_string(data." <> col.name <> ")"
            _ -> "data." <> col.name
          }
      }
    })

  string.join(value_extractions, ", ")
}

fn sql_type_to_gleam_type(
  sql_type: String,
  nullable: option.Option(Bool),
) -> String {
  let base_type = case sql_type {
    "INTEGER" -> "Int"
    "TEXT" -> "String"
    "REAL" -> "Float"
    _ -> "String"
  }

  case nullable |> option.unwrap(False) {
    True -> "Option(" <> base_type <> ")"
    False -> base_type
  }
}

fn sql_type_to_decoder(sql_type: String) -> String {
  case sql_type {
    "INTEGER" -> "decode.int"
    "TEXT" -> "decode.string"
    "REAL" -> "decode.float"
    _ -> "decode.string"
  }
}

fn string_to_pascal_case(str: String) -> String {
  str
  |> string.split("_")
  |> list.map(string.capitalise)
  |> string.concat
}
