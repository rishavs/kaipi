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
    #     ECR.render "src/views/components/navbar.ecr"
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
    begin

        params = URI::Params.parse(ctx.request.body.not_nil!.gets_to_end)

        # Cleanup data
        email       = params["email"].downcase
        rawpassword = params["password"]

        if !Kaipi.validate_as_email(email) || 
            !Kaipi.validate_as_password(rawpassword)
            raise Kaipi::BadRequestError.new("Form data validation failed")
        end

        # Generate some data
        unqid = UUID.random.to_s
        encpass = Crypto::Bcrypt::Password.create(rawpassword, cost: 10)
        thumb = "https://robohash.org/set_set4/128x128/#{unqid}.jpeg"
        
        # DB operations
        query1 =  "insert into users (unqid, user_thumb) 
                values ($1, $2)
                Returning unqid"
        result1 = Kaipi::DATA.scalar query1,
                unqid, thumb

        query2 =  "insert into AUTH_BASIC (user_id_ref, user_email, user_password) 
                values ($1, $2, $3)
                Returning user_id_ref"
        result2 = Kaipi::DATA.scalar query2,
                result1.to_s, email, encpass

        Log.info { "User with email " + email + "was successfully created" }

    rescue ex : Kaipi::BadRequestError | Kaipi::ForbiddenError
        Log.error(exception: ex) { ex.message }
        return {
            "status"     => "error",
            "message"    => "400 rabbits say that there is some error in the Form data. Please fix and try again",
        }
    rescue ex
        Log.error(exception: ex) { ex.message }
        return {
            "status"     => "error",
            "message"    => "502 Orcs have laid siege to the server. Please try again after some time",
        }
    else
        return {
            "status"    => "success",
            "message"   => "Your account was sucessfully registered",
            "data"      => {
                "unqid" =>  result2.to_s,
            }
        }
    end


end
