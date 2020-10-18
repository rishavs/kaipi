module Kaipi

    class About

        def self.fetch ()
            DATA.scalar "SELECT NOW()"
        end

        def self.render(ctx)
            data = fetch()

            ECR.render "src/views/pages/about.ecr"
   
         end

    end

end