class BlankSlate
  instance_methods.each { |meth| undef_method(meth) unless meth =~ /^__/ }
end

module Riot
  class Message < BlankSlate
    def initialize(*phrases)
      @chunks = []; _inspect(phrases)
    end

    def to_s; @chunks.join.strip; end

    def method_missing(meth, *phrases, &blk) push(meth.to_s.gsub('_', ' ')); _inspect(phrases); end

    def comma(str, *phrases) _concat([", ", str]); _inspect(phrases); end
    def but(*phrases); comma("but", *phrases); end
    def not(*phrases); comma("not", *phrases); end
    def push(str) _concat([" ", str]); end
  private
    def _concat(chunks) @chunks.concat(chunks); self; end
    def _inspect(phrases) phrases.each { |phrase| push(phrase.inspect) }; self; end
  end # Message
end # Riot