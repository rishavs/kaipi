module Kaipi::Actions

    class Users
    
        def self.list (env)
 
            users = User.all("ORDER BY created_at DESC")
            if users
                users.each do |user|
                    puts user.username
                end
    
                {   "status": "success",
                    "data": users
                }.to_json
    
            else 
                {   "status": "success",
                    "message":   "No Users so far"
                }.to_json
            end

        end

    end
end