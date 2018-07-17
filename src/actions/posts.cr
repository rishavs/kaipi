module Kaipi::Actions
    class Posts
        def self.create (env)
            begin
                post = Post.new
                auth_token = env.request.headers["Authorization"].lchop("Bearer ")
                author = Actions::Auth.parse_jwt_token(auth_token)
                post.title          = env.params.json["title"].as(String)
                post.content        = env.params.json["content"].as(String)
                post.link           = env.params.json["link"].as(String)
                post.thumb          = env.params.json["thumb"].as(String)
                post.author         = author["username"].to_s
                post.save
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
                if post.errors.size > 0
                    err_content = Errors::Content.badrequest
                    err_content["details"] = post.errors[0].field.to_s + " " + post.errors[0].message.to_s
                    env.response.status_code = 422
                    err_content.to_json
                else
                    pp "added post"
                    {   "status": "success",
                        "message": "Post was inserted into the database",
                        "data": {"unqid": post.unqid, "title": post.title}
                    }.to_json
                end
            end
        end

        def self.list(env)
            # auth_token = env.request.headers["Authorization"].lchop("Bearer ")
            # author = Actions::Auth.parse_jwt_token(auth_token)

            # pp "author is"
            # pp author

            posts = Post.all("ORDER BY created_at DESC")
            if posts
                posts.each do |post|
                    puts post.title
                end
    
                {   "status": "success",
                    "data": posts
                }.to_json
    
            else 
                {   "status": "success",
                    "message":   "No posts so far"
                }.to_json
            end

        end

    end
end