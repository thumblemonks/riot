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
      @evaluated_expectation = true
      @expects_raise = false
      expectation(true, &block)
    end

    def to_s
      "#{@description}: expected [#{@expectation}]"
    end

    def not(&block)
      @evaluated_expectation = false
      expectation(@expectation, &block)
    end

    def equals(expectation, &block)
      expectation(expectation, &block)
    end

    def raises(expectation, &block)
      @expects_raise = true
      expectation(expectation, &block)
    end

    def run(binding_scope)
      begin
        actual = binding_scope.instance_eval(&@block)
      rescue Exception => e
        errored("#{binding_scope} asserted #{self}, but errored with: #{e.to_s}", e) unless @expects_raise
        actual = e.class
      end
      assert(@expectation == actual, "#{binding_scope} asserted #{self}, but received [#{actual}] instead")
    end
  private
    def expectation(expectation, &block)
      @expectation = expectation
      @block = block if block_given?
      self
    end
    
    def errored(message, e); raise Error.new(message, e); end

    def assert(evaluation, message)
      @evaluated_expectation == evaluation || raise(Failure, message)
    end
  end # Assertion
end # Protest