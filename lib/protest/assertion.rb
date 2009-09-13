module Protest

  class Assertion
    attr_reader :raised, :to_s, :description
    def initialize(description, target, &block)
      @description = @to_s = description
      actualize(target, &block)
    end

    def actual
      @default_failure = @failure = nil if @default_failure
      @actual
    end

    def fail(message)
      @failure = Failure.new(message, self) unless error?
    # rescue Failure => e
    #   @failure = e # Smelly (for now)
    end

    def failure?; !@failure.nil?; end
    # def error?; !failure? && !raised.nil?; end
    def error?; !@raised.nil?; end
    def passed?; !(failure? || error?); end
    def result; @failure || error; end
  private
    def actualize(target, &block)
      @actual = target.instance_eval(&block)
      @default_failure = fail("expected true, not #{@actual.inspect}") unless @actual
    rescue Exception => e
      @raised = e
    end

    def error
      Error.new("errored with #{@raised}", self, @raised) if error?
    end
  end # Assertion
end # Protest