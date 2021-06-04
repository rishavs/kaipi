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

        
        # -----------------------------------------
        # Routing
        # -----------------------------------------
        url_parts       = ctx.request.path.split('/', limit: 4, remove_empty: true)
        url_resource    = url_parts[0]?
        url_identifier  = url_parts[1]?
        url_verb        = url_parts[2]?

        # All routes should support 3 types of query params - error, info and success to feed into the error, info and success bars.
        # Some routes will also support other query params like sortedby

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
            data = nil
            page = ECR.render "src/views/pages/about.ecr"
            view = view_render(ctx, page)
            ctx.response.print view

        when {"GET", "u", "me", "signup"}
            data = nil
            page = ECR.render "src/views/pages/signup.ecr"
            view = view_render(ctx, page)
            ctx.response.print view
        when {"POST", "u", "me", "signup_user"}
            pp result = post_signup_user(ctx)
            
            if result["status"] == "error"
                ctx.response.headers.add "Location", "/u/me/signup?" + URI::Params.encode({"error" => result["message"].to_s})
                ctx.response.status_code = 302
                ctx.response.close
            else
                ctx.response.headers.add "Location", "/home?"+ URI::Params.encode({"success" => result["message"].to_s})
                ctx.response.status_code = 302
                ctx.response.close
            end

        when {"GET", "u", "me", "signin"}
            data = nil
            page = ECR.render "src/views/pages/signin.ecr"
            view = view_render(ctx, page)
            ctx.response.print view
        when {"POST", "u", "me", "signin_user"}
            pp result = post_signin_user(ctx)
            
            if result["status"] == "error"
                ctx.response.headers.add "Location", "/u/me/signin?" + URI::Params.encode({"error" => result["message"].to_s})
                ctx.response.status_code = 302
                ctx.response.close
            else
                usercookie = HTTP::Cookie.new("usertoken", result["data"]["sessionid"].to_s, "/", Time.utc + 24.hours)
                usercookie.http_only = true
                usercookie.domain = SERVERHOST
                usercookie.secure = true
                # usercookie.samesite = HTTP::Cookie::SameSite.new(1)
                ctx.response.headers.add "Location", "/home?"+ URI::Params.encode({"success" => result["message"].to_s})
                ctx.response.status_code = 302
                ctx.response.close
            end

        # Catch-all routes    
        when {"GET", nil, nil, nil}
            data = nil
            page = ECR.render "src/views/pages/home.ecr"
            view = view_render(ctx, page)
            ctx.response.print view
        else
            data = 404
            page = ECR.render "src/views/pages/error.ecr"
            view = view_render(ctx, page)
            ctx.response.print view
        end

    end

    address = server.bind_tcp SERVERHOST, SERVERPORT
    Log.info { "Server started listening on http://#{address}" }
    puts "------------------------------------------------"
    server.listen
end
