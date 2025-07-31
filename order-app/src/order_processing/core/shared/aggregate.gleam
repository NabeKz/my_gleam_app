import gleam/list

/// 汎用のfrom_eventsパターン
/// 初期状態からイベントリストを適用して最終状態を構築する
pub fn from_events(
  initial_state: aggregate,
  events: List(event),
  apply_fn: fn(aggregate, event) -> aggregate,
) -> aggregate {
  apply_events(initial_state, events, apply_fn)
}

/// 汎用のapply_eventsパターン
/// アグリゲートにイベントリストを順次適用する
pub fn apply_events(
  aggregate: aggregate,
  events: List(event),
  apply_fn: fn(aggregate, event) -> aggregate,
) -> aggregate {
  list.fold(events, aggregate, apply_fn)
}