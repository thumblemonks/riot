module Riot
  class BlankSlate
    instance_methods.each do |meth|
      undef_method(meth) unless meth.to_s =~ /^(__|object_id)/
    end
  end

  # A Message is similar in nature (but not implementation) to a string buffer; you put some strings in and
  # calling {#to_s} will generate a single new string. What's special abnout Message is how you get strings
  # into it. By convention, any method called on a Message that isn't defined will have its name turned into
  # a string and any underscores replaced with spaces. This happens for each method call and those small
  # messages are chained together at the end. For instance:
  #
  #   message = Riot::Message.new
  #   message.hello_world.to_s
  #    => "hello world"
  #
  #   message.whats_the_news.to_s
  #    => "hello world whats the news"
  #
  # For every method called it is also acceptable to pass any number of arguments. These arguments will be
  # added to the final message after having `inspect` called on them. Another for instance:
  #
  #   message = Riot::Message.new
  #   message.expected([1, 2, 3], "foo").not([3, 2, 1], "bar")
  #   message.to_s
  #    => 'expected [1, 2, 3], "foo", not [3, 2, 1], "bar"'
  #
  # This is useful for - and was originally intended for - generating pass/fail messages from
  # {Riot::AssertionMacro assertion macros}.
  class Message < BlankSlate

    # Creates a new Message instance.
    #
    # @param [Array<Object>] *phrases an array of objects to be inspected
    def initialize(*phrases)
      @chunks = []
      _inspect(phrases)
    end

    # Generates the string value of the built-up message.
    #
    # @return [String]
    def to_s; @chunks.join.strip; end
    alias_method :inspect, :to_s

    # Converts any method call into a more readable string by replacing underscores with spaces. Any
    # arguments to the method are inspected and appended to the final message. Blocks are currently ignored.
    #
    # @param [String, Symbol] meth the method name to be converted into a more readable form
    # @param [Array<Object>] *phrases an array of objects to be inspected
    # @return [Riot::Message] this instance for use in chaining calls
    def method_missing(meth, *phrases, &block)
      push(meth.to_s.gsub('_', ' '))
      _inspect(phrases)
    end

    # Adds a comma then the provided phrase to this message.
    #
    #   Riot::Message.new.hello.comma("world").to_s
    #    => "hello, world"
    #
    # @param [String] str any string phrase to be added after the comma
    # @param [Array<Object>] *phrases an array of objects to be inspected
    # @return [Riot::Message] this instance for use in chaining calls
    def comma(str, *phrases)
      _concat([", ", str])
      _inspect(phrases)
    end

    # Adds the string ", but".
    #
    #   Riot::Message.new.any_number.but(52).to_s
    #    => "any number, but 52"
    #
    # @param [Array<Object>] *phrases an array of objects to be inspected
    # @return [Riot::Message] this instance for use in chaining calls
    def but(*phrases); comma("but", *phrases); end

    # Adds the string ", not".
    #
    #   Riot::Message.new.expected_freebies.not("$1.50").to_s
    #    => 'expected freebies, not "$1.50"'
    #
    # @param [Array<Object>] *phrases an array of objects to be inspected
    # @return [Riot::Message] this instance for use in chaining calls
    def not(*phrases); comma("not", *phrases); end

  private
    def push(str)
      _concat([" ", str])
    end

    def _concat(chunks)
      @chunks.concat(chunks)
      self
    end

    def _inspect(phrases)
      unless phrases.empty?
        push(phrases.map { |phrase| phrase.inspect }.join(", "))
      end
      self
    end
  end # Message
end # Riot
