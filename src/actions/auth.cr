module Kaipi::Actions

    class Auth
    
        def self.register (env)
            begin
                new_user = User.new
                new_user.username = env.params.body["username"].as(String)
                new_user.password = env.params.body["password"].as(String)
                new_user.save
            rescue ex
                pp ex
                {
                    "status" => "error",
                    "message" => ex.message.to_s
                }
            else
                if new_user.errors.size > 0
                    {
                        "status" => "error",
                        "message" => new_user.errors[0].message.to_s
                    }
                else
                    {   "status" => "success",
                        "message" => "User was successfully registered!",
                        "data" => {
                            "unqid" => new_user.unqid, 
                            "username" => new_user.username
                        }
                    }
                end
            end
        end

        def self.login(env)
            begin
                uname = env.params.json["username"].as(String)
                pass = env.params.json["password"].as(String)
                user = User.find_by(username: uname)
            rescue ex : JSON::ParseException | KeyError
                pp ex.message
                err_content = Errors::Content.badrequest
                err_content["details"] = ex.message.to_s
                env.response.status_code = 400
                err_content.to_json
            rescue ex : TypeCastError 
                pp ex.message
                err_content = Errors::Content.badrequest
                err_content["details"] = ex.message.to_s
                env.response.status_code = 422
                err_content.to_json
            rescue ex
                pp ex
                err_content = Errors::Content.badrequest
                err_content["details"] = ex.message.to_s
                env.response.status_code = 500
                err_content.to_json
            else
                if user && Crypto::Bcrypt::Password.new(user.password_hash.not_nil!) == pass
                    puts "The password matches"
                    token = generate_jwt_token(user.unqid, user.username)
                    {   "status": "success",
                        "message": "Password was succesfully verified",
                        "data": token
                    }.to_json
                else
                    puts "The password doesnt matches"
                    {   "status": "error",
                        "message": "Password is wrong"
                    }.to_json
                end
            end
        end

        def self.check (env)
            auth_token = env.request.headers["Authorization"].lchop("Bearer ")
            author = Actions::Auth.parse_jwt_token(auth_token)
        end

        def self.generate_jwt_token (uid, uname)
            exp = Time.now.epoch + 6000000
            payload = { "unqid" => uid, "username" => uname, "exp" => exp }
            token = JWT.encode(payload, ENV["SECRET_JWT"], "HS256")
        end

        def self.parse_jwt_token (token)
            payload, header = JWT.decode(token, ENV["SECRET_JWT"], "HS256")
            user = { "unqid" => payload["unqid"], "username" => payload["username"]}
        end
    end
end