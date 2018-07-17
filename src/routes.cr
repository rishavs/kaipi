module Kaipi
    # add_context_storage_type(payload = Hash(String, Array(String) | String)?)
    res = {
        "status" => "none",
        "message" => "none"
    }

    get "/" do
        render "src/views/pages/Home.ecr", "src/views/Layout.ecr"
    end
    get "/about" do
        data = {"ongo": "bongo"}.to_json
        render "src/views/pages/About.ecr", "src/views/Layout.ecr"
    end
    get "/register" do
        render "src/views/pages/Register.ecr", "src/views/Layout.ecr"
    end
    post "/register" do |env|
        res = Actions::Auth.register (env)
        env.set("store", res.to_json)
        if res["status"] == "error" 
            # render "src/views/pages/Register.ecr", "src/views/Layout.ecr"
            env.redirect "/register"
        else
            pp res
            render "src/views/pages/Welcome.ecr", "src/views/Layout.ecr"
        end
    end

    get "/login" do
        render "src/views/pages/Login.ecr", "src/views/Layout.ecr"
    end

end