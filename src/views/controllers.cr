module Kaipi
   
   # -----------------------------------------
   # Layout Controller
   # -----------------------------------------
   def self.layout_render (navbar : String, sidebar : String | Nil, page : String )
      ECR.render "src/views/layout.ecr"
   end

   # -----------------------------------------
   # Component Controllers
   # -----------------------------------------
   def self.navbar_render ()
      data = nil
      ECR.render "src/views/components/navbar.ecr"
   end

   # def self.errorbar_render ()
   #    ECR.render "src/views/components/navbar.ecr"
   # end

   def self.sidebar_render ()
      data = nil
      ECR.render "src/views/components/sidebar.ecr"
   end

   # -----------------------------------------
   # Page Controllers
   # -----------------------------------------
   def self.home_page_render ()
      data = nil
      ECR.render "src/views/pages/home.ecr"
   end

   def self.about_page_render ()
      data = nil
      ECR.render "src/views/pages/about.ecr"
   end

   def self.signin_page_render ()
      data = nil
      ECR.render "src/views/pages/signin.ecr"
   end

   def self.signup_page_render ()
      data = nil
      ECR.render "src/views/pages/signup.ecr"
   end

   def self.error_page_render (code : Int)
      data = code
      ECR.render "src/views/pages/error.ecr"
   end
end


# -----------------------------------------
# Action Controllers
# -----------------------------------------
def self.post_signup_user (ctx)

   pp! params = HTTP::Params.parse(ctx.request.body.not_nil!.gets_to_end)
   ctx.response.headers.add "Location", "/about"
   ctx.response.status_code = 302

   # if body = ctx.request.body
   #    pp! params = HTTP::Params.parse(body.gets_to_end)
   #    ctx.response.print params
   #  else
   #    ctx.response.print "You didn't POST any data :("
   #  end
end
