env "dev" {
  src = "file://db/schema.sql"
  url = "sqlite://database.sqlite3"
  dev = "sqlite://dev.sqlite3"
  migration {
    dir = "file://db/migrations"
  }
}

env "prod" {
  src = "file://db/schema.sql" 
  url = "postgres://user:pass@localhost/tickets"
  migration {
    dir = "file://db/migrations"
  }
}