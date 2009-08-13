module Protest

  class Assertion
    attr_reader :raised, :to_s
    def initialize(description, target, &block)
      @description = @to_s = description
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
  private
    def actualize(target, &block)
      @actual = target.instance_eval(&block)
      @default_failure = failure("expected true, not #{@actual.inspect}") unless @actual
    rescue Exception => e
      @raised = e
    end
  end # Assertion
end # Protest