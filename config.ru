require './app'
run Sinatra::Application

log = File.new("./log/app.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)

# optionally to sync logs while the server is running
$stderr.sync = true
$stdout.sync = true
