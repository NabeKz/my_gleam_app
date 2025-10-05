import features/account/application/error
import features/account/application/port
import gleam/result
import shared/db
import sqlight

pub fn load_events(_connection: db.Connection) -> port.LoadEvents {
  fn(_aggregate_id) { Ok(port.EventStream([], 0)) }
}

pub fn append_events(connection: db.Connection) -> port.AppendEvents {
  fn(aggregate_id, version, _events) {
    db.Sql(
      statement: "
        insert into journals (
          aggregate_type,
          aggregate_id,
          version,
          event_type,
          event
        ) values (
          ?,?,?,?,?,?
        )
      ",
      args: [
        sqlight.text("account"),
        sqlight.text(aggregate_id),
        sqlight.int(version),
        sqlight.text(""),
        sqlight.text(""),
        sqlight.text(""),
      ],
    )
    |> db.exec_with(connection)
    |> result.map_error(fn(err) { error.AppendFailed(err.message) })
  }
}
