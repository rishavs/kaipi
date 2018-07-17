def index_posts (env)
    query = Crecto::Repo::Query
        .order_by("posts.id DESC")
    dataset = Crecto::Repo.all(Post, query)

    env.response.content_type = "application/json"
    dataset.to_json unless dataset.nil?

end

def create_post(env)

    puts "POST request received for data:"

    pp env.params.json

    data = Post.new

    begin
        # data = Post.from_json(env.params.json)
        
        data.title          = env.params.json["title"].as(String)
        data.slug           = env.params.json["slug"].as(String)
        data.content        = env.params.json["content"].as(String)
        data.link           = env.params.json["link"].as(String)
        data.thumb          = env.params.json["thumb"].as(String)
        data.user_id        = env.params.json["user_id"].as(Int64)

    rescue ex : JSON::ParseException
        env.response.status_code = 400
    rescue ex : TypeCastError | KeyError
        env.response.status_code = 422
    else
        pp data

        changeset = Crecto::Repo.insert(data)
        if changeset.valid? == false
            puts "Changeset is INVALID!" 
            env.response.status_code = 500
            puts "Changeset errors are: #{changeset.errors }" if !changeset.errors.empty?
        else
            puts "\nThe item was successfully ADDED. ID:#{changeset.instance.id}\n"

            env.response.content_type = "application/json"
            { "message": "SUCCESS: Item added as id:#{changeset.instance.id}",
                "data": data}.to_json
        end
    end
end

def show_post (env)
    id = env.params.url["id"]
    data = Crecto::Repo.get(Post, id)
    if data
        env.response.content_type = "application/json"
        data.to_json
    else
        env.response.status_code = 500
    end
end


# def save_post(env)
#     id = env.params.url["id"]
#     data = Crecto::Repo.get(Post, id)

#     if data
#         data.title = env.params.body["post_title"]
#         data.content = env.params.body["post_content"]

#         changeset = Crecto::Repo.update(data)
#         puts "Changeset is INVALID!" if changeset.valid? == false
#         puts "Changeset errors are: #{changeset.errors }" if !changeset.errors.empty?
#         puts "\nThe item was successfully UPDATED. ID:#{changeset.instance.id}\n"

#         env.redirect "/p/#{changeset.instance.id}" 
#     else
#         "Unable to fetch Item data"
#     end
# end

# def delete_an_item(env)
#     id = env.params.url["id"]

#     post = Crecto::Repo.get(Post, id)
#     post.as(Post) unless post.nil?

#     if post
#         changeset = Crecto::Repo.delete(post)

#         puts "Changeset is INVALID!" if changeset.valid? == false
#         puts "Changeset errors are: #{changeset.errors }" if !changeset.errors.empty?
#         puts "\nThe item was successfully DELETED. ID:#{changeset.instance.id}\n"

#         env.redirect "/p/index" 
#     else
#         "Unable to get the post"
#     end
# end