require "sqlite3"

CREATE_SQL = <<-SQL
  CREATE TABLE IF NOT EXISTS contacts (
    id INTEGER PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    age INTEGER NOT NULL
  );
SQL

INSERT_SQL = <<-SQL
  INSERT INTO contacts (id, name, age) VALUES (?, ?, ?);
SQL

DB.open("sqlite3:data.db?journal_mode=wal&synchronous=normal&busy_timeout=5000") do |db|
  db.exec CREATE_SQL

  db.transaction do |tx|
    conn = tx.connection

    500.times do |t|
      id = t + 1
      conn.exec INSERT_SQL, id, "Name #{id}", id + 20
    end
  end
end
