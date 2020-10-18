module Kaipi

    class Navbar

        def self.fetch ()
            nil
        end

        def self.render(ctx)
            data = fetch()

            ECR.render "src/views/components/navbar.ecr"
   
        end

    end

end