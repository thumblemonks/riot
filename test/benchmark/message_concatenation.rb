require 'benchmark'

class BlankSlate
  instance_methods.each { |meth| undef_method(meth) unless meth =~ /^__/ }
end

class NormalMessage < BlankSlate
  def initialize(*phrases)
    @message = ""; _phrase(*phrases)
  end
  
  def to_s; @message; end

  def method_missing(meth, *phrases, &blk) push(meth.to_s.gsub('_', ' ')); _phrase(*phrases); end

  def comma(str, *phrases) raise Exception, "Whoops - comma"; end
  def but(*phrases); comma("but", *phrases); end
  def not(*phrases); comma("not", *phrases); end
  def push(str) raise Exception, "Whoops - push"; end
private
  def _concat(str) (@message << str).strip!; self; end
  def _phrase(*phrases) phrases.each { |phrase| push(phrase.inspect) }; self; end
end # Message

# +

class PlusMessage < NormalMessage
  def comma(str, *phrases) _concat(", " + str); _phrase(*phrases); end
  def push(str) _concat(" " + str); end
end # Message

# <<

class AppendMessage < NormalMessage
  def comma(str, *phrases) _concat(", " << str); _phrase(*phrases); end
  def push(str) _concat(" " << str); end
end # Message

# Experimental

class ExperimentalMessage < BlankSlate
  def initialize(*phrases)
    @chunks = []; _inspect(phrases)
  end
  
  def to_s; @chunks.join; end

  def method_missing(meth, *phrases, &blk) push(meth.to_s.gsub('_', ' ')); _inspect(phrases); end

  def comma(str, *phrases) _concat([", ", str]); _inspect(phrases); end
  def but(*phrases); comma("but", *phrases); end
  def not(*phrases); comma("not", *phrases); end
  def push(str) _concat([" ", str]); end
private
  def _concat(chunks) @chunks.concat(chunks); self; end
  def _inspect(phrases) phrases.each { |phrase| push(phrase.inspect) }; self; end
end # Message

#
# Benchmarking

Benchmark.bmbm do |x|
  def message_test(klass)
    STDOUT.puts(klass.new.comma("yes").push("no").foo.bar("baz").to_s)
    10_000.times do
      klass.new.comma("yes").push("no").foo.bar("baz").to_s
    end
  end

  x.report("+ based message") do
    message_test(PlusMessage)
  end

  x.report("<< based message") do
    message_test(AppendMessage)
  end

  x.report("experimental message") do
    message_test(ExperimentalMessage)
  end
end

