module Riot
  # A {Riot::Situation} is virtually a stack frame for a single context run. The intent is for all blocks to
  # be evaluated against an instance of a Situation. Given the following superfluous context:
  #
  #   context "Foo" do # block-1
  #
  #     setup do # block-2
  #       {:bar => "baz"}
  #     end
  #
  #     asserts "its hash" do # block-3
  #       topic
  #     end.equals do # block-4
  #       {:bar => "baz"}
  #     end
  #
  #   end # Foo
  #
  # In this example, block-1 will be evaluated against a {Riot::Context} instance. Whereas block-2, block-3,
  # and block-4 will all be evaluated against the same Situation instance. Situation instances (situations) 
  # are bound to a single context run; they are not shared across context runs, regardless of their position
  # in the test tree structure.
  #
  # What is gained from doing it this way is:
  # * variables, methods, etc. set in one situation do not contaminate any others
  # * variables, methods, etc. defined during a context run do not stick with the context itself
  # * which means that testing state is independent of the test definitions themselves
  class Situation

    # Returns the currrently tracked value of +topic+
    #
    # @return [Object] whatever the topic is currently set to
    def topic
      @_topic ||= nil
    end

    # This is where a setup block is actually evaluated and the +topic+ tracked.
    #
    # @param [lambda] &block a setup block
    # @return [Object] the current topic value
    def setup(&block)
      @_topic = self.instance_eval(&block)
    end

    # This is where a defined helper is born. A method is defined against the current instance of +self+.
    # This method will not be defined on any other instances of Situation created afterwards.
    #
    # @param [Symbol, String] name the name of the helper being defined
    # @param [lambda] &block the code to execute whennever the helper is called
    def helper(name, &block)
      (class << self; self; end).send(:define_method, name, &block)
    end

    # Anonymously evaluates any block given to it against the current instance of +self+. This is how
    # {Riot::Assertion assertion} and {Riot::AssertionMacro assertion macro} blocks are evaluated,
    # for instance.
    #
    # @param [lambda] &block the block to evaluate against +self+
    # @return [Object] whatever the block would have returned
    def evaluate(&block)
      self.instance_eval(&block)
    end
  end # Situation
end # Riot
