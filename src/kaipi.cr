require "dotenv"
require "db"
require "pg"
require "http/server"
require "ecr"
require "crypto/bcrypt/password"

require "./models.cr"
require "./handlers.cr"
require "./**"
# require "./errors.cr"

# require "./actions/*"



module Kaipi
    VERSION = "0.1.0"

    SERVERPORT = 5000
    SERVERHOST = "0.0.0.0"
        
    puts "Starting the app ..."
    Dotenv.load
    puts "Initializing Database..."

    DATA = DB.open ENV["DATABASE_URL"] 
    
    cnn_time = DATA.scalar "SELECT NOW()"
    Log.info{"Connected to DB at: #{cnn_time}"}

    server = HTTP::Server.new([
        APIvsWebHandler.new,
        HTTP::StaticFileHandler.new(public_dir = "./public", fallthrough = true, directory_listing = false),
        HTTP::ErrorHandler.new,
        HTTP::LogHandler.new,
        HTTP::CompressHandler.new,
    ]) do |ctx|
        puts "------------------------------------------------"
        # pp ctx.request
        url_parts = ctx.request.path.split('/', limit: 4, remove_empty: true)

        url_resource =     url_parts[0]?
        url_identifier =   url_parts[1]?
        url_verb =         url_parts[2]?

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
            navbar = navbar_render()
            sidebar = sidebar_render()
            errorbar = nil
            page = about_page_render()
            view = layout_render(navbar, sidebar, page)
            ctx.response.print view

        when {"GET", "u", "me", "signup"}
            navbar = navbar_render()
            sidebar = sidebar_render()
            errorbar = nil
            page = signup_page_render()
            view = layout_render(navbar, sidebar, page)
            ctx.response.print view
        when {"POST", "u", "me", "signup_user"}
            pp data = post_signup_user(ctx)
            
            if data["status"] == "error"
                ctx.response.print data
            else
                ctx.response.headers.add "Location", "/about"
                ctx.response.status_code = 302
                ctx.response.print "signedup"
            end

        when {"GET", "u", "me", "signin"}
            navbar = navbar_render()
            sidebar = sidebar_render()
            errorbar = nil
            page = signin_page_render()
            view = layout_render(navbar, sidebar, page)
            ctx.response.print view

        # Catch-all routes    
        when {"GET", nil, nil, nil}
            navbar = navbar_render()
            sidebar = sidebar_render()
            errorbar = nil
            page = home_page_render()
            view = layout_render(navbar, sidebar, page)
            ctx.response.print view

        else
            navbar = navbar_render()
            sidebar = sidebar_render()
            errorbar = nil
            page = error_page_render(404)
            view = layout_render(navbar, sidebar, page)
            ctx.response.print view
        end

    end

    address = server.bind_tcp SERVERPORT
    Log.info { "Server started listening on http://#{address}" }
    puts "------------------------------------------------"
    server.listen
end
