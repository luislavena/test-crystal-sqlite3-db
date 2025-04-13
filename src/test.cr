require "sqlite3"

puts "preview_mt: #{{{ flag?(:preview_mt) }}}"

db = DB.open("sqlite3:data.db?journal_mode=wal&synchronous=normal&busy_timeout=5000")

COUNT = 100

COUNT.times do |i|
  spawn do
    rand_id = rand(1..500)

    puts db.scalar("SELECT age FROM contacts WHERE id = ? LIMIT 1;", rand_id).as(Int64)
  end
end

sleep 5.seconds
Fiber.yield

db.close
