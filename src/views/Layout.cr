module Kaipi
    class Layout
        def initialize(@content : String)
        end
    
        ECR.def_to_s "src/views/Layout.ecr"
    end
end