module Protest
  class Failure < Exception; end
  class Error < Exception
    def initialize(message, e)
      super(message)
      set_backtrace(e.backtrace)
    end
  end

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
      begin
        actual = context.instance_eval(&@block)
      rescue Exception => e
        message = "#{context} asserted #{self}, but errored with: #{e.to_s}"
        raise Error.new(message, e)
      end
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