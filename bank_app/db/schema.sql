CREATE TABLE journals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    aggregate_type TEXT NOT NULL,
    event JSON NOT NULL,
    created_at TEXT NOT NULL
);