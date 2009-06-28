module Protest
  class Failure < Exception; end

  class Assertion
    def initialize(description, expectation, &block)
      @description = description
      @expectation = expectation
      @block = block
    end

    def equals(expectation, &block)
      @expectation, @block = expectation, block
      self
    end

    def run(context)
      actual = context.instance_eval(&@block)
      @expectation == actual || raise(Failure, "#{@description}: expected #{@expectation} but received #{actual}")
    end
  end # Assertion
end # Protest