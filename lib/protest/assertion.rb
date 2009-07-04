module Protest

  class Assertion
    attr_reader :raised
    def initialize(description, target, &block)
      @description = description
      actualize(target, &block)
    end

    def actual
      @default_failure = @failure = nil if @default_failure
      @actual
    end

    def failure(message)
      raise Failure.new(message, self)
    rescue Failure => e
      @failure = e # Smelly (for now)
    end

    def error
      Error.new("errored with #{raised}", self, raised) if error?
    end

    def failure?; @failure; end
    def error?; !failure? && raised; end
    def passed?; !failure? && !error?; end
    def result; @failure || error; end
    def to_s; @description; end
  private
    def actualize(target, &block)
      @actual = target.instance_eval(&block)
      @default_failure = base_assertion
    rescue Exception => e
      @raised = e
    end

    def base_assertion
      failure("expected true, not #{@actual.inspect}") unless @actual
    end
  end # Assertion

  # Denial will evaulate to true if the assertion failed in some way. Errors pass through. A Failure
  # is generated if the assertion actually passed.
  class Denial < Assertion
    def actual
      @actual # Do not forget default failure unless a failure is thrown
    end
    
    alias :actual_failure :failure
    def failure(message)
      @default_failure = @failure = nil # this is a good thing
    end
  private
    def base_assertion
      actual_failure("expected assertion to fail") if @actual
    end
  end # Denial

end # Protest