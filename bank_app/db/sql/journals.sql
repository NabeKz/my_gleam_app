-- name: create_journal
INSERT INTO journals (
  aggregate_type,
  aggregate_id,
  version,
  event_type,
  event,
  created_at
) VALUES (
  ?, ?, ?, ?, ?, ?
);

-- name: get_journals
SELECT
  id,
  aggregate_type,
  aggregate_id,
  version,
  event_type,
  event,
  created_at
FROM
  journals
;
