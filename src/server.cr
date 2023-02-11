require "http/server"
require "sqlite3"

class RandomContactApp
  include HTTP::Handler

  getter db : DB::Database | DB::Connection

  def initialize(@db)
  end

  def call(context)
    rand_id = rand(1..500)
    name = fetch_name(rand_id)

    context.response.content_type = "text/plain"
    context.response.print "Hello #{name}!"
  end

  private def fetch_name(id)
    db.scalar("SELECT name FROM contacts WHERE id = ? LIMIT 1;", id).as(String)
  end
end

db = DB.open("sqlite3://./contacts.db")
db.setup_connection do |conn|
  # 1. Avoid writers to block readers by using WAL mode
  # Ref. https://sqlite.org/pragma.html#pragma_journal_mode
  conn.exec "PRAGMA journal_mode = WAL;"

  # 2. Use normal synchronization to speed up operations (good combo with WAL)
  # Ref. https://sqlite.org/pragma.html#pragma_synchronous
  conn.exec "PRAGMA synchronous = NORMAL;"

  # 3. Increases cache size available (from 2MB to 16MB in KB)
  # Ref. https://sqlite.org/pragma.html#pragma_cache_size
  conn.exec "PRAGMA cache_size = -16000;"

  # 4. Allow waiting on periodic write locks from replication (or other process)
  # Refs.
  # - https://www.sqlite.org/pragma.html#pragma_busy_timeout
  # - https://litestream.io/tips/#busy-timeout
  conn.exec "PRAGMA busy_timeout = 5000;"
end

app = RandomContactApp.new(db)
logger = HTTP::LogHandler.new
server = HTTP::Server.new([logger, app] of HTTP::Handler)

Signal::INT.trap do
  puts "Shutting down."
  server.close
end

server.bind_tcp "0.0.0.0", 8080

puts "Listening on:"
server.addresses.each do |addr|
  puts "- #{addr}"
end
puts "Use Ctrl-C to stop"

server.listen

puts "Shutdown completed."

# cleanup
db.close
