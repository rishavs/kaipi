require "dotenv"
require "db"
require "pg"
require "http/server"
require "ecr"

require "./handlers.cr"
require "./views/*"
# require "./errors.cr"
# require "./models.cr"
# require "./actions/*"
require "./routes.cr"


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
        APIvsWebHandler.new,
        HTTP::StaticFileHandler.new(public_dir = "./public", fallthrough = true, directory_listing = false),
        HTTP::ErrorHandler.new,
        HTTP::LogHandler.new,
        HTTP::CompressHandler.new,
    ]) do |ctx|
        puts "------------------------------------------------"
        pp! url_parts = ctx.request.path.split('/', limit: 4, remove_empty: true)

        pp! url_resource =     url_parts[0]?
        pp! url_identifier =   url_parts[1]?
        pp! url_verb =         url_parts[2]?

        case {ctx.request.method, url_resource, url_identifier, url_verb}

        # -----------------------------------------
        # API Routes
        # -----------------------------------------
        when {"GET", "api", "v1", "dosomething"}
            ctx.response.print "Hello world!"
            # if ctx.request.query_params["id"]? && ctx.request.query_params["name"]?
            #     ctx.response.respond_with_status(200, "Signing up - " + ctx.request.query_params["id"] + ", " + ctx.request.query_params["name"])
            # else
            #     ctx.response.respond_with_status(400, "Missing id?")
            # end

        # -----------------------------------------
        # Web Routes
        # -----------------------------------------
        when {"GET", "about", nil, nil}
            navbar = Navbar.render()
            sidebar = Sidebar.render()
            errorbar = nil
            page = About.render(ctx)
            view = Layout.render(navbar, page, sidebar)
            ctx.response.print view

        # Catch-all routes    
        when {"GET", nil, nil, nil}
            navbar = Navbar.render()
            sidebar = Sidebar.render()
            errorbar = nil
            page = Home.render(ctx)
            view = Layout.render(navbar, page, sidebar)
            ctx.response.print view

        else
            navbar = Navbar.render()
            sidebar = Sidebar.render()
            errorbar = nil
            page = Error.render(404)
            view = Layout.render(navbar, page, sidebar)
            ctx.response.print view
        end

    end

    address = server.bind_tcp SERVERPORT
    puts "Server listening on http://#{address}"
    puts "------------------------------------------------"
    server.listen
end
