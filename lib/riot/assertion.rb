module Riot
  class Assertion < RunnableBlock
    class << self
      def macros; @@macros ||= {}; end

      def register_macro(name, assertion_macro, expect_exception=false)
        macros[name.to_s] = assertion_macro
      end
    end

    def initialize(description, negative=false, &definition)
      super(description, &definition)
      @negative = negative
      @expectings, @expectation_block = [], nil
      @macro = AssertionMacro.default
    end

    def run(situation)
      @expectings << situation.evaluate(&@expectation_block) if @expectation_block
      actual = situation.evaluate(&definition)
      macro_arguments = [(@macro.expects_exception? ? nil : actual), *@expectings]
      @negative ? @macro.devaluate(*macro_arguments) : @macro.evaluate(*macro_arguments)
    rescue Exception => e
      @macro.expects_exception? ? @macro.evaluate(e, *@expectings) : @macro.error(e)
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
  end # Assertion
end # Riot
