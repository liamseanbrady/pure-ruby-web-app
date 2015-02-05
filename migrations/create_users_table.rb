require 'sqlite3'

@db = SQLite3::Database.new "data/surfing.sqlite3"
statement = "CREATE TABLE users (id INTEGER PRIMARY KEY NOT NULL, name VARCHAR(255), username VARCHAR(255), password VARCHAR(255), created_at DATETIME)"
@db.execute statement