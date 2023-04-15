require "http/server"
require "sqlite3"

class RandomContactApp
  include HTTP::Handler

  getter db : DB::Database

  def initialize(@db)
  end

  def call(context)
    rand_id = rand(1..500)
    age = fetch_age(rand_id)

    context.response.content_type = "text/plain"
    context.response.print "Age: #{age}!"
  end

  private def fetch_age(id) : Int64
    {% if flag?(:use_conn) %}
      db.using_connection do |conn|
        conn.scalar("SELECT age FROM contacts WHERE id = ? LIMIT 1;", id).as(Int64)
      end
    {% else %}
      db.scalar("SELECT age FROM contacts WHERE id = ? LIMIT 1;", id).as(Int64)
    {% end %}
  end
end

db = DB.open("sqlite3:data.db?journal_mode=wal&synchronous=normal&busy_timeout=5000")

app = RandomContactApp.new(db)
server = HTTP::Server.new([app] of HTTP::Handler)

Process.on_interrupt do
  puts "Shutting down."
  server.close
end

server.bind_tcp "0.0.0.0", 8080, reuse_port: true

puts "Listening on:"
server.addresses.each do |addr|
  puts "- #{addr}"
end
puts "Use Ctrl-C to stop"

server.listen

puts "Shutdown completed."

Fiber.yield

# cleanup
db.close
