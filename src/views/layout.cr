module Kaipi
   class Layout
      def self.render (navbar : String, page : String, )
         ECR.render "src/views/layout.ecr"
      end

   end
end