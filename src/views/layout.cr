module Kaipi
   class Layout
      def self.render (navbar : String, page : String, sidebar : String | Nil )
         ECR.render "src/views/layout.ecr"
      end

   end
end