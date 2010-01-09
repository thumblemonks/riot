module Riot
  class Message
    def initialize(*phrases)
      @message = ""; _phrase(*phrases)
    end
    
    def to_s; @message; end

    def method_missing(meth, *phrases, &blk) _push(meth.to_s.gsub('_', ' ')); _phrase(*phrases); end

    def comma(str) _concat(", " + str); end
    def but; comma("but"); end
    def not(*phrases); comma("not"); _phrase(*phrases); end
  private
    def _concat(str) (@message << str).strip!; self; end
    def _push(str) _concat(" " + str); end
    def _phrase(*phrases) phrases.each { |o| _push(o.inspect) }; self; end
  end # Message
end # Riot