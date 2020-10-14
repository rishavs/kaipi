require "dotenv"
require "db"
require "pg"
require "http/server"
require "ecr"

# require "./views/*"
# require "./errors.cr"
# require "./models.cr"
# require "./actions/*"
# require "./routes.cr"
# require "./handlers.cr"

module Kaipi
    VERSION = "0.1.0"

    SERVERPORT = 3000
    SERVERHOST = "0.0.0.0"
        
    puts "Starting the app ..."
    Dotenv.load
    puts "Initializing Database..."

    # Routes:
    # /resource/id/verb
    # /p/1234/
    # /p/1234/
    # /p/new/create
    # /p/1234/edit


    # services = {
    #     "/"                        => Noir::Services::Register,
    #     "/login"                        => Noir::Services::Register,
    #     "/register"                        => Noir::Services::Register,
    #     "/p/"                        => Noir::Services::Register,
    #     "/t/"                        => Noir::Services::Register,
    #     "/c/"                        => Noir::Services::Register,
    # }
    DATA = DB.open ENV["DATABASE_URL"]
    
    cnn_time = DATA.scalar "SELECT NOW()"
    puts "Connected to DB at: #{cnn_time}"

    # class Content
    #     def initialize(@str : String)
    #     end
      
    #     ECR.def_to_s "src/views/pages/Welcome.ecr"
    # end

    # content = Content.new("Sexy").to_s

  
    server = HTTP::Server.new([
        HTTP::ErrorHandler.new,
        HTTP::LogHandler.new,
        HTTP::CompressHandler.new,
        # HTTP::StaticFileHandler.new("."),
    ]) do |ctx|
        ctx.response.content_type = "text/html; charset=UTF-8"

        name = ctx.request.path
        navbar = ECR.render "src/views/components/navbar.ecr"
        sidebar = ECR.render "src/views/components/sidebar.ecr"
        content = ECR.render "src/views/pages/home.ecr"

        ctx.response.print ECR.render "src/views/layout.ecr"

        pp url = ctx.request.path.rstrip(" / ")
        # if services.has_key?(url) 
        #     services[url].new(context)

        # # Will remove this else part in prod as the routes are a known quantity
        # else
        #     context.response.status_code = 404
        #     res = {
        #         "status" => 404,
        #         "message" => "Wrong Route"
        #     }
        #     context.response.print(res.to_json)
        # end
        
    end

    address = server.bind_tcp SERVERPORT
    puts "Server listening on http://#{address}"
    puts "------------------------------------------------"
    server.listen
end
