// Define an environment named "local"
env "local" {
  src = "file://schema.sql"
  url = "sqlite://database.sqlite3?_fk=1"
  dev = "sqlite://database?mode=memory&_fk=1"
}
