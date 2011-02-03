module Riot
  # An Assertion is the engine behind evaluating a single test that can be reported on. When +asserts+
  # or +denies+ is used, the description and assertion block are used to generate a single Assertion
  # instance. When running an Assertion, a [Riot::Situation] instance is required for data scoping. The
  # result of calling run will be a status tuple that can be used for reporting.
  #
  # In general, you won't be spending much time in here.
  class Assertion < RunnableBlock
    class << self
      # Returns the list of assertion macros that have been successfully registered
      #
      # @return [Hash<Riot::AssertionMacro>]
      def macros; @@macros ||= {}; end

      # Registers a [Riot::AssertionMacro] class to a given +name+. Name is distinct, which means any future
      # registrations for the same name will replace previous ones. +name+ will always be converted to a
      # string first.
      #
      # @param [String, Symbol] name The handle the macro will be associated with
      # @param [Class] assertion_macro A [Riot::AssertionMacro] class
      def register_macro(name, assertion_macro)
        macros[name.to_s] = assertion_macro
      end
    end

    # Setups a new Assertion. By default, the assertion will be a "positive" one, which means +evaluate+ will
    # be call on the associated assertion macro. If +negative+ is true, +devaluate+ will be called instead.
    # Not providing a definition block is just kind of silly since it's used to generate the +actual+ value
    # for evaluation by a macro.
    #
    # @param [String] definition A small description of what this assertion is testing
    # @param [Boolean] negative Determines whether this is a positive or negative assertion
    # @param [lambda] definition The block that will return the +actual+ value when eval'ed
    def initialize(description, negative=false, &definition)
      super(description, &definition)
      @negative = negative
      @expectings, @expectation_block = [], nil
      @macro = AssertionMacro.default
    end

    # Given a {Riot::Situation}, execute the assertion definition provided to this Assertion, hand off to an
    # assertion macro for evaluation, and then return a status tuple. If the macro to be used expects any
    # exception, catch the exception and send to the macro; else just return it back.
    #
    # Currently supporting 3 evaluation states: :pass, :fail, and :error
    # 
    # @param [Riot::Situation] situation An instance of a {Riot::Situation}
    # @return [Array<Symbol, String>] array containing evaluation state and a descriptive explanation
    def run(situation)
      @expectings << situation.evaluate(&@expectation_block) if @expectation_block
      actual = situation.evaluate(&definition)
      assert((@macro.expects_exception? ? nil : actual), *@expectings)
    rescue Exception => e
      @macro.expects_exception? ? assert(e, *@expectings) : @macro.error(e)
    end
  private
    def enhance_with_macro(name, *expectings, &expectation_block)
      @expectings, @expectation_block = expectings, expectation_block
      @macro = self.class.macros[name.to_s].new
      raise(NoMethodError, name) unless @macro
      @macro.file, @macro.line = caller.first.match(/(.*):(\d+)/)[1..2]
      self
    end
    alias :method_missing :enhance_with_macro

    def assert(*arguments)
      @negative ? @macro.devaluate(*arguments) : @macro.evaluate(*arguments)
    end
  end # Assertion
end # Riot
