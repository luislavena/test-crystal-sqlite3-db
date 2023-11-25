require "pg"

CREATE_SQL = <<-SQL
  CREATE TABLE IF NOT EXISTS contacts (
    id INTEGER PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    age BIGINT NOT NULL
  );
SQL

INSERT_SQL = <<-SQL
  INSERT INTO contacts (id, name, age) VALUES ($1, $2, $3);
SQL

DB_URL = ENV.fetch("DB_URL", "postgres://postgres@localhost/postgres")
puts "Using: '#{DB_URL}'"

DB.open(DB_URL) do |db|
  db.exec CREATE_SQL

  db.transaction do |tx|
    conn = tx.connection

    500.times do |t|
      id = t + 1
      conn.exec INSERT_SQL, id, "Name #{id}", id + 20
    end
  end
end
