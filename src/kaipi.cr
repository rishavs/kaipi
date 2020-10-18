require "dotenv"
require "db"
require "pg"
require "http/server"
require "ecr"

require "./views/*"
# require "./errors.cr"
# require "./models.cr"
# require "./actions/*"
require "./routes.cr"
# require "./handlers.cr"

module Kaipi
    VERSION = "0.1.0"

    SERVERPORT = 3000
    SERVERHOST = "0.0.0.0"
        
    puts "Starting the app ..."
    Dotenv.load
    puts "Initializing Database..."

    DATA = DB.open ENV["DATABASE_URL"]
    
    cnn_time = DATA.scalar "SELECT NOW()"
    puts "Connected to DB at: #{cnn_time}"

    server = HTTP::Server.new([
        HTTP::ErrorHandler.new,
        HTTP::LogHandler.new,
        HTTP::CompressHandler.new,
        # HTTP::StaticFileHandler.new("."),
    ]) do |ctx|
        ctx.response.content_type = "text/html; charset=UTF-8"
        Router.run (ctx)
    end

    address = server.bind_tcp SERVERPORT
    puts "Server listening on http://#{address}"
    puts "------------------------------------------------"
    server.listen
end
