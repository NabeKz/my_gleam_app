import gleam/dynamic/decode
import gleam/option.{type Option}

// Atlas schema inspect JSONの型定義とデコーダー

pub type AtlasSchema {
  AtlasSchema(schemas: List(Schema))
}

pub type Schema {
  Schema(name: String, tables: List(Table))
}

pub type Table {
  Table(name: String, columns: List(Column), primary_key: Option(PrimaryKey))
}

pub type Column {
  Column(name: String, type_: String, null: Option(Bool))
}

pub type PrimaryKey {
  PrimaryKey(parts: List(PrimaryKeyPart))
}

pub type PrimaryKeyPart {
  PrimaryKeyPart(column: String)
}

// デコーダー関数群

pub fn atlas_schema_decoder() -> decode.Decoder(AtlasSchema) {
  use schemas <- decode.field("schemas", decode.list(schema_decoder()))
  decode.success(AtlasSchema(schemas))
}

fn schema_decoder() -> decode.Decoder(Schema) {
  use name <- decode.field("name", decode.string)
  use tables <- decode.field("tables", decode.list(table_decoder()))
  decode.success(Schema(name, tables))
}

fn table_decoder() -> decode.Decoder(Table) {
  use name <- decode.field("name", decode.string)
  use columns <- decode.field("columns", decode.list(column_decoder()))
  use primary_key <- decode.optional_field(
    "primary_key",
    option.None,
    decode.optional(primary_key_decoder()),
  )
  decode.success(Table(name, columns, primary_key))
}

fn column_decoder() -> decode.Decoder(Column) {
  use name <- decode.field("name", decode.string)
  use type_ <- decode.field("type", decode.string)
  use null <- decode.optional_field(
    "null",
    option.None,
    decode.optional(decode.bool),
  )
  decode.success(Column(name, type_, null))
}

fn primary_key_decoder() -> decode.Decoder(PrimaryKey) {
  use parts <- decode.field("parts", decode.list(primary_key_part_decoder()))
  decode.success(PrimaryKey(parts))
}

fn primary_key_part_decoder() -> decode.Decoder(PrimaryKeyPart) {
  use column <- decode.field("column", decode.string)
  decode.success(PrimaryKeyPart(column))
}
