module Riot

  class Assertion
    attr_reader :raised, :to_s, :description
    def initialize(description, situation, &block)
      @description = @to_s = description
      actualize(situation, &block)
    end

    def actual
      @default_failure = @failure = nil if @default_failure
      @actual
    end

    def fail(message)
      @failure = Failure.new(message, self) unless errored?
    end

    def failed?; !@failure.nil?; end
    def errored?; !@raised.nil?; end
    def passed?; !(failed? || errored?); end
    def result; @failure || error; end
  private
    def actualize(situation, &block)
      @actual = situation.instance_eval(&block)
      @default_failure = fail("expected true, not #{@actual.inspect}") unless @actual == true
    rescue Exception => e
      @raised = e
    end

    def error
      Error.new("errored with #{@raised}", self, @raised) if errored?
    end
  end # Assertion
end # Riot