module Kaipi

    def self.validate_as_email(email : String)
        reg = Regex.new("^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$")
        res = reg.matches?(email) && (8 <= email.size <= 64) ? true : false
    end
    def self.validate_as_password(pass : String)
        res = (8 <= pass.size <= 64) ? true : false
    end

    
    # class Comment
    #     property unqid : String
    #     property parent_id : String
    #     property level : Int32
    #     property post_id : String
    #     property content : String
    #     property author_id : String
    #     property author_nick : String
    #     property author_flair : String | Nil
    #     property children_ids = [] of String
      
    #     def initialize(@unqid, @level,  @post_id, @parent_id, @content, @author_id, @author_nick)
    #     end
    # end

    # class Post
    #     property unqid : String
    #     property title : String
    #     property link : Int32
    #     property content : String
    #     property author_id : String
    #     property author_nick : String
    #     property author_flair : String | Nil
    #     property children_ids = [] of String
      
    #     def initialize(@unqid, @title,  @link, @content, @author_id, @author_nick, @author_flair)
    #     end
    # end

    # class User
    #     property unqid : String
    #     property email : String
    #     property password : String
    #     property nickname : Int32
    #     property flair : String
      
    #     def initialize(@unqid, @email,  @password, @nickname, @flair)
    #     end
    # end

end