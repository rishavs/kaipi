module Kaipi

    class Error

        def self.fetch ()
            # DATA.scalar "SELECT NOW()"
        end

        def self.render(code : Int)
            data = code

            ECR.render "src/views/pages/error.ecr"
   
         end

    end

end