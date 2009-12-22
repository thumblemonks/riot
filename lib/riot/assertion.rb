module Riot
  class Assertion < RunnableBlock
  
    def initialize(description, &definition)
      super
      @expectings, @expect_exception, @expectation_block = [], false, nil
      @macro = AssertionMacro.default
    end

    class << self
      def macros; @assertions ||= {}; end

      def register_macro(name, assertion_macro, expect_exception=false)
        macros[name.to_s] = [expect_exception, assertion_macro.new]
      end
    end

    def method_missing(name, *expectings, &expectation_block)
      @expect_exception, @macro = self.class.macros[name.to_s]
      if @macro
        @expectings, @expectation_block = expectings, expectation_block
        self
      else
        raise NoMethodError, name
      end
    end

    def run(situation)
      @expectings << situation.evaluate(&@expectation_block) if @expectation_block
      process_macro(situation, @expect_exception) do |actual|
        @macro.evaluate(actual, *@expectings)
      end
    end

  private
    def process_macro(situation, expect_exception)
      actual = situation.evaluate(&definition)
      yield(expect_exception ? nil : actual)
    rescue Exception => e
      expect_exception ? yield(e) : @macro.error(e)
    end
  end # Assertion
end # Riot
