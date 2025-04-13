require "http/server"

class HelloApp
  include HTTP::Handler

  def call(context)
    context.response.content_type = "text/plain"
    context.response.print "Hello world!"
  end
end

app = HelloApp.new
server = HTTP::Server.new([app] of HTTP::Handler)

Process.on_terminate do
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
