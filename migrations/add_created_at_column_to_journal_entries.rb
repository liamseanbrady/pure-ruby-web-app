require 'sqlite3'

@db = SQLite3::Database.new "data/surfing.sqlite3"
statement = "ALTER TABLE journal_entries ADD COLUMN created_at DATETIME"
@db.execute statement