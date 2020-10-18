module Kaipi

    class Sidebar

        def self.fetch ()
            nil
        end

        def self.render(ctx)
            data = fetch()

            ECR.render "src/views/components/sidebar.ecr"
   
        end

    end

end