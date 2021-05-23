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

    SERVERPORT = 5000
    SERVERHOST = "0.0.0.0"
        
    puts "Starting the app ..."
    Dotenv.load
    puts "Initializing Database..."

    # DATA = DB.open ENV["DATABASE_URL"] 
    
    # cnn_time = DATA.scalar "SELECT NOW()"
    # puts "Connected to DB at: #{cnn_time}"

    server = HTTP::Server.new([
        HTTP::ErrorHandler.new,
        HTTP::LogHandler.new,
        HTTP::CompressHandler.new,
        HTTP::StaticFileHandler.new(public_dir = "./public", fallthrough = true, directory_listing = false),
    ]) do |ctx|
        ctx.response.content_type = "text/html; charset=UTF-8"

        url_parts = ctx.request.path.split("/", limit: 2, remove_empty: true)

        pp! url_resource =     url_parts[0]?
        pp! url_identifier =   url_parts[1]?
        pp! url_verb =         url_parts[2]?

        # Render shared views and components
        navbar = Navbar.render()

        case {url_resource, url_identifier, url_verb}

        when {"about", nil, nil}
            sidebar = Sidebar.render()
            # sidebar = ECR.render "src/views/components/sidebar.ecr"
            page = About.render(ctx)
            view = Layout.render(navbar, page, sidebar)

        # Catch-all routes    
        when {nil, nil, nil}
            sidebar = Sidebar.render()
            page = Home.render(ctx)
            view = Layout.render(navbar, page, sidebar)
        else
            sidebar = nil
            page = Error.render(404)
            view = Layout.render(navbar, page, sidebar)
        end

        ctx.response.print view


    end

    address = server.bind_tcp SERVERPORT
    puts "Server listening on http://#{address}"
    puts "------------------------------------------------"
    server.listen
end
