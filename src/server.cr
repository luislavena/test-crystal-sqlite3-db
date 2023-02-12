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

db = DB.open("sqlite3://./contacts.db?journal_mode=wal&synchronous=normal&cache_size=-16000&busy_timeout=5000")

app = RandomContactApp.new(db)
server = HTTP::Server.new([app] of HTTP::Handler)

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
