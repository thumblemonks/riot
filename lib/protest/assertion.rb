module Protest
  class Failure < Exception; end

  class Assertion
    def initialize(description, &block)
      @description = description
      @expectation = true
      @block = block
    end

    def to_s
      "#{@description}: expected [#{@expectation}]"
    end

    def equals(expectation, &block)
      @expectation = expectation
      @block = block if block_given?
      self
    end

    def run(context)
      actual = context.instance_eval(&@block)
      failure = "#{context} asserted #{self}, but received [#{actual}] instead"
      @expectation == actual || raise(Failure, failure)
    end
  end # Assertion
end # Protest