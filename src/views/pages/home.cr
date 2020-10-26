module Kaipi

    class Home

        def self.fetch ()
            # DATA.scalar "SELECT NOW()"
        end

        def self.render(ctx)
            data = fetch()

            ECR.render "src/views/pages/home.ecr"
   
         end

    end

end