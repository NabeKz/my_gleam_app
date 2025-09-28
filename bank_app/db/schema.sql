CREATE TABLE journals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    aggregate_type TEXT NOT NULL,
    aggregate_id TEXT NOT NULL,
    version INTEGER NOT NULL,
    event_type TEXT NOT NULL,
    event TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE(aggregate_type, aggregate_id, version)
);

CREATE INDEX journals_aggregate_idx
    ON journals (aggregate_type, aggregate_id);
