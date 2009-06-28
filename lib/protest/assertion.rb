module Protest
  class Failure < Exception; end

  class Assertion
    def initialize(description, &block)
      @description = description
      @boolean_expectation = true
      expectation(true, &block)
    end

    def to_s
      "#{@description}: expected [#{@expectation}]"
    end

    def not(&block)
      @boolean_expectation = false
      expectation(@expectation, &block)
    end

    def equals(expectation, &block)
      expectation(expectation, &block)
    end

    def run(context)
      actual = context.instance_eval(&@block)
      assert(@expectation == actual, "#{context} asserted #{self}, but received [#{actual}] instead")
    end
  private
    def expectation(expectation, &block)
      @expectation = expectation
      @block = block if block_given?
      self
    end
    
    def assert(expression, msg)
      @boolean_expectation == expression || raise(Failure, msg)
    end
  end # Assertion
end # Protest