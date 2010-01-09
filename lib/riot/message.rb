class BlankSlate
  instance_methods.each { |m| undef_method m unless m =~ /^__/ }
end

module Riot
  class Message < BlankSlate
    def initialize(*phrases)
      @message = ""; _phrase(*phrases)
    end
    
    def to_s; @message; end

    def method_missing(meth, *phrases, &blk) _push(meth.to_s.gsub('_', ' ')); _phrase(*phrases); end

    def comma(str, *phrases) _concat(", " + str); _phrase(*phrases); end
    def but(*phrases); comma("but", *phrases); end
    def not(*phrases); comma("not", *phrases); end
  private
    def _concat(str) (@message << str).strip!; self; end
    def _push(str) _concat(" " + str); end
    def _phrase(*phrases) phrases.each { |o| _push(o.inspect) }; self; end
  end # Message
end # Riot