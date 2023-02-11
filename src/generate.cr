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

DB.open("sqlite3://./contacts.db") do |db|
  db.exec CREATE_SQL

  db.transaction do
    500.times do |t|
      id = t + 1
      db.exec INSERT_SQL, id, "Name #{id}", id + 20
    end
  end
end
