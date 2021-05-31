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

    # -----------------------------------------
    # Action Controllers
    # -----------------------------------------
    def self.post_signup_user (ctx)
        begin

            params = URI::Params.parse(ctx.request.body.not_nil!.gets_to_end)

            # Cleanup data
            email       = params["email"].downcase
            rawpassword = params["password"]

            if !validate_as_email(email) || 
                !validate_as_password(rawpassword)
                raise BadRequestError.new("Form data validation failed")
            end

            # Generate some data
            unqid = UUID.random.to_s
            encpass = Crypto::Bcrypt::Password.create(rawpassword, cost: 10)
            thumb = "https://robohash.org/set_set4/128x128/#{unqid}.jpeg"
            
            # DB operations
            query1 =  "insert into users (unqid, user_thumb) 
                    values ($1, $2)
                    Returning unqid"
            result1 = DATA.scalar query1,
                    unqid, thumb

            query2 =  "insert into AUTH_BASIC (user_id_ref, user_email, user_password) 
                    values ($1, $2, $3)
                    Returning user_id_ref"
            result2 = DATA.scalar query2,
                    result1.to_s, email, encpass

            Log.info { "User with email " + email + " was successfully created" }

        rescue ex : BadRequestError | ForbiddenError
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

    def self.post_signin_user (ctx)
        begin

            params = URI::Params.parse(ctx.request.body.not_nil!.gets_to_end)

            # Cleanup data
            email       = params["email"].downcase
            rawpassword = params["password"]

            if !validate_as_email(email) || 
                !validate_as_password(rawpassword)
                raise BadRequestError.new("Form data validation failed")
            end

            # Get the password for the comparison
            query1 = "select USER_ID_REF, user_email, user_password 
                from auth_basic where user_email = $1"

            pp! result1 = DATA.query_one? query1, 
                email, 
                as: {user_id: String, user_email: String, user_password: String}

            if !result1
                raise AuthenticationError.new("The Username or Password is wrong") 
            end

            if !Crypto::Bcrypt::Password.new(result1[:user_password]).verify(rawpassword) # => true
                raise AuthenticationError.new("Wrong password attempt for user with email" + result1[:user_email])
            end   

            Log.info {"Logging in user with email" + result1[:user_email]}

            # Get the account details
            query2 = "select unqid, user_nick, user_flair, user_thumb, user_role, user_level, user_stars,
                banned_till from users where unqid = $1"
                
            pp! result2 = DATA.query_one? query2, 
                result1[:user_id], 
                as: {unqid: String, user_nick: String, user_flair: String, user_thumb: String,  user_role: String, user_level: String, user_stars: Int, banned_till: Time | Nil}
            
            if !result2            
                raise AuthenticationError.new("The Username or Password is wrong 2")  
            end

            # Check if user is banned
            if banned_time = result2[:banned_till]
                if (banned_time < Time.utc)
                    raise AuthorizationError.new("You have been banned till " + result2[:banned_till].to_s)
                end
            end

            # Generate the session id
            pp! sessionid = Random::Secure.urlsafe_base64(128).delete('-').delete('_').byte_slice(0, 128)

            # Insert session into session store
            query3 = "insert into sessions (unqid, user_id) 
                values ($1, $2)
                Returning unqid"

            result3 = DATA.scalar query3,
                sessionid, result2[:unqid]

            Log.info { "User with email " + email + " was successfully signed in" }

        rescue ex : BadRequestError | KeyError
            Log.error(exception: ex) { ex.message }
            return {
                "status"     => "error",
                "message"    => "400 rabbits say that there is some error in the Form data. Please fix and try again",
            }
        rescue ex : AuthenticationError
            Log.error(exception: ex) { ex.message }
            return {
                "status"     => "error",
                "message"    => "401 mistakes in the Username and Password. Squash Squash and try again!",
            }
        rescue ex : AuthorizationError
            Log.error(exception: ex) { ex.message }
            return {
                "status"     => "error",
                "message"    => "All 403 sparrow moms think you need some time out. " + ex.message.to_s,
            }
        rescue ex
            Log.error(exception: ex) { ex.message }
            return {
                "status"     => "error",
                "message"    => "502 Orcs have laid siege to the server. Please try again after they have left!",
            }
        else
            return {
                "status"    => "success",
                "message"   => "The user was sucessfully logged in",
                "data"      => {
                    "auth_type"     => "basic",
                    "sessionid"     => sessionid,
                    "user_email"    => email,
                    "user_nick"     => result2[:user_nick],
                    "user_thumb"    => result2[:user_thumb],
                    "user_flair"    => result2[:user_flair],
                    "user_role"     => result2[:user_role],
                    "user_level"    => result2[:user_level],
                    "user_stars"    => result2[:user_stars],
                }
            }
        end
    end

end


