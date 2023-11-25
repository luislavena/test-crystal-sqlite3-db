require "http/server"
require "pg"

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
    db.scalar("SELECT age FROM contacts WHERE id = $1 LIMIT 1;", id).as(Int64)
  end
end

DB_URL = ENV.fetch("DB_URL", "postgres://postgres@localhost/postgres")
puts "Using: '#{DB_URL}'"

db = DB.open(DB_URL)

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
