import gleam/dynamic/decode
import gleam/list
import gleam/option
import gleam/string
import sqlight

pub opaque type Conn {
  Conn(value: sqlight.Connection)
}

pub type WhereCondition {
  Eq(String, sqlight.Value)
  Like(String, sqlight.Value)
  Gt(String, sqlight.Value)
  Lt(String, sqlight.Value)
  Gte(String, sqlight.Value)
  Lte(String, sqlight.Value)
}

pub type Error =
  sqlight.Error

pub type ErrorMessage {
  NotFound
  MultiRecordFound
  SqlError(message: String)
}

pub const string = sqlight.text

pub fn create(sql: String, conn: Conn) -> Result(Nil, Error) {
  sqlight.exec(sql, conn.value)
}

pub fn exec(
  sql: String,
  conn: Conn,
  values: List(sqlight.Value),
) -> Result(Nil, Error) {
  let result = sqlight.query(sql, conn.value, values, decode.success(Nil))
  case result {
    Ok(_) -> Ok(Nil)
    Error(error) -> Error(error)
  }
}

pub fn query(
  sql: String,
  conn: Conn,
  values: List(sqlight.Value),
  decoder: decode.Decoder(a),
) -> Result(List(a), Error) {
  sqlight.query(sql, conn.value, values, decoder)
}

pub fn open(name: String) -> Conn {
  let assert Ok(conn) = sqlight.open(name)
  Conn(conn)
}

pub fn with_connection(name: String, f: fn(Conn) -> a) {
  let conn = open(name)
  let value = f(conn)
  let assert Ok(Nil) = sqlight.close(conn.value)
  value
}

pub fn transaction(conn: Conn) {
  let _ = sqlight.exec("begin transaction", conn.value)
  let _ = sqlight.exec("commit transaction", conn.value)
}

pub fn escape(values: List(String)) -> String {
  list.map(values, fn(it) { "'" <> it <> "'" })
  |> string.join(",")
}

pub fn handle_find_result(
  result: Result(List(a), Error),
) -> Result(a, ErrorMessage) {
  case result {
    Ok([first]) -> Ok(first)
    Ok([]) -> Error(NotFound)
    Ok([_, ..]) -> Error(MultiRecordFound)
    Error(err) -> Error(SqlError(err.message))
  }
}

pub fn insert_with_values(
  table_name: String,
  values: List(#(String, sqlight.Value)),
) -> #(String, List(sqlight.Value)) {
  let #(columns, values) = list.unzip(values)
  let columns = columns |> string.join(",")
  let placeholders = list.repeat("?", list.length(values)) |> string.join(",")
  let sql =
    "insert into "
    <> table_name
    <> " ("
    <> columns
    <> ") values ("
    <> placeholders
    <> ")"

  #(sql, values)
}

pub fn select_with_where(
  table_name: String,
  wheres: List(WhereCondition),
) -> #(String, List(sqlight.Value)) {
  let base_sql = "select * from " <> table_name

  case wheres {
    [] -> #(base_sql <> ";", [])
    _ -> {
      let #(where_clause, values) = build_where_clause(wheres)
      let sql = base_sql <> " where " <> where_clause <> ";"
      #(sql, values)
    }
  }
}

fn build_where_clause(
  wheres: List(WhereCondition),
) -> #(String, List(sqlight.Value)) {
  let conditions_and_values = {
    use it <- list.map(wheres)
    case it {
      Eq(col, val) -> #(col <> " = ?", val)
      Like(col, val) -> #(col <> " LIKE ?", val)
      Gt(col, val) -> #(col <> " > ?", val)
      Lt(col, val) -> #(col <> " < ?", val)
      Gte(col, val) -> #(col <> " >= ?", val)
      Lte(col, val) -> #(col <> " <= ?", val)
    }
  }

  let #(conditions, values) = list.unzip(conditions_and_values)
  let where_clause = string.join(conditions, " and ")
  #(where_clause, values)
}

pub fn maybe_condition(
  make_condition: fn(sqlight.Value) -> WhereCondition,
  value: option.Option(a),
  to_value: fn(a) -> sqlight.Value,
) -> List(WhereCondition) {
  case value {
    option.Some(val) -> [val |> to_value |> make_condition]
    option.None -> []
  }
}

pub fn update_with_values(
  table_name: String,
  update_values: List(#(String, sqlight.Value)),
  where_condition: #(String, sqlight.Value),
) -> #(String, List(sqlight.Value)) {
  let #(columns, values) = list.unzip(update_values)
  let set_clause = {
    use it <- list.map(columns)
    it <> " = ?"
  }

  let sql =
    "update "
    <> table_name
    <> " set "
    <> set_clause |> string.join(", ")
    <> " where "
    <> where_condition.0
    <> " = ?"
  let all_values = list.append(values, [where_condition.1])

  #(sql, all_values)
}
