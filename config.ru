require './app'

log = File.new("log/app.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)

$stderr.sync = true
$stdout.sync = true

run Sinatra::Application
