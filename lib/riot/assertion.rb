module Riot
  class Assertion < RunnableBlock
    class << self
      def macros; @macros ||= {}; end

      def register_macro(name, assertion_macro, expect_exception=false)
        macros[name.to_s] = [expect_exception, assertion_macro.new]
      end
    end

    def initialize(description, &definition)
      super
      @expectings, @expect_exception, @expectation_block = [], false, nil
      @macro = AssertionMacro.default
    end

    def run(situation)
      @expectings << situation.evaluate(&@expectation_block) if @expectation_block
      actual = situation.evaluate(&definition)
      @macro.evaluate((@expect_exception ? nil : actual), *@expectings)
    rescue Exception => e
      @expect_exception ? yield(e) : @macro.error(e)
    end

  private
    def enhance_with_macro(name, *expectings, &expectation_block)
      @expect_exception, @macro = self.class.macros[name.to_s]
      raise(NoMethodError, name) unless @macro
      @expectings, @expectation_block = expectings, expectation_block
      self
    end
    alias :method_missing :enhance_with_macro
  end # Assertion
end # Riot
