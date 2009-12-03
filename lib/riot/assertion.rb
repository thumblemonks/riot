module Riot
  class Assertion < RunnableBlock
  
    def initialize(description, &definition)
      super
      @expectings, @expect_exception, @expectation_block = [], false, nil
      @assertion_block = lambda do |actual|
        actual ? Assertion.pass : Assertion.fail("Expected non-false but got #{actual.inspect} instead")
      end
    end

    class << self
      def pass() [:pass]; end
      def fail(message) [:fail, message]; end
      def error(e) [:error, e]; end
      def assertions; @assertions ||= {}; end

      # TODO: Make everyone switch to 1.8.7 or above so we can go mostly stateless again.
      # Had to do this for 1.8.6 compatibility  {:() I'm a sad sock monkey
      def assertion(name, expect_exception=false, &assertion_block)
        assertions[name] = [expect_exception, assertion_block]
        class_eval <<-EOC
          def #{name}(*expectings, &expectation_block)
            @expectings, @expectation_block = expectings, expectation_block
            @expect_exception, @assertion_block = Assertion.assertions[#{name.inspect}]
            self
          end
        EOC
      end
    end

    def run(situation)
      @expectings << situation.evaluate(&@expectation_block) if @expectation_block
      process_macro(situation, @expect_exception) { |actual| @assertion_block.call(actual, *@expectings) }
    end

  private
    def process_macro(situation, expect_exception)
      actual = situation.evaluate(&definition)
      yield(expect_exception ? nil : actual)
    rescue Exception => e
      expect_exception ? yield(e) : Assertion.error(e)
    end
  end # Assertion
end # Riot
