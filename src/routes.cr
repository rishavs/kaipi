require "./views/*"
require "./views/pages/*"
require "./views/components/*"

module Kaipi

    struct Route 
        property resource :     String = ""
        property identifier :   String = ""
        property verb :         String = ""
        
        def initialize(url : String)
            # Remove all leading and trailing whitespaces.
            url = url.lstrip("/").rstrip(" / ")
            arr = url.split("/")

            @resource =     arr[0]? ? arr[0] : ""
            @identifier =   arr[1]? ? arr[1] : ""
            @verb =         arr[2]? ? arr[2] : ""

        end
    end

    class Router
        def self.run(ctx)
            route = Route.new(ctx.request.path)
            navbar = Navbar.render(ctx)

            case {route.resource, route.identifier, route.verb}
            when {"about", "", ""}
                # Cove::Misc.about(ctx)
                cnn_time = DATA.scalar "SELECT NOW()"

                sidebar = ECR.render "src/views/components/sidebar.ecr"
                page = About.render(ctx)
                view = Layout.render(navbar, page)
                # view = Generate.new(navbar, page).to_s

            # # Routes for Posts resource
            # when {"p", "new", ""}
            #     Cove::Posts.new_post(ctx)
 
            # when {"p", "new", ""}
            #     Cove::Posts.create(ctx)

            # when {"p", route.identifier, ""}
            #     Cove::Posts.read(ctx, route.identifier)
 
            # when {"c", "new", ""}
            #     Cove::Comment.create(ctx)

            # # Routes for Register resource
            # when {"register", "", ""}
            #     Cove::Register.show(ctx)
            # when {"register", "", ""}
            #     Cove::Register.adduser(ctx)

            # # Routes for Login resource
            # when {"login", "", ""}
            #     Cove::Login.show(ctx)
            # when {"login", "", ""}
            #     Cove::Login.login(ctx)
            # when {"logout","",""}
            #     Cove::Login.logout(ctx)

            # Catch-all routes    
            when {"", "", ""}
                # Cove::Posts.list(ctx)
                cnn_time = DATA.scalar "SELECT NOW()"
                sidebar = ECR.render "src/views/components/sidebar.ecr"
                page = ECR.render "src/views/pages/home.ecr"
                ctx.response.print ECR.render "src/views/layout.ecr"
            else
                # Cove::Errors.error404(ctx)
                cnn_time = DATA.scalar "SELECT NOW()"
                sidebar = ECR.render "src/views/components/sidebar.ecr"
                page = ECR.render "src/views/pages/error404.ecr"
                ctx.response.print ECR.render "src/views/layout.ecr"
            end

            ctx.response.print view

        end

        def self.redirect(path, ctx)
            ctx.response.headers.add "Location", path
            ctx.response.status_code = 302
        end

    end
end