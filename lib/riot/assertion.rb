module Riot
  class Assertion
    attr_reader :raised, :to_s, :description, :situation
    def initialize(description, situation, &block)
      @description = @to_s = description
      @situation = situation
      actualize(situation, &block)
    end

    def actual
      no_failure_if_default_failure_recorded
      @actual
    end

    def fail(message)
      @failure = Failure.new("#{description}: #{message}") unless errored?
    end

    def passed?; !(failed? || errored?); end
    def failed?; !@failure.nil?; end
    def errored?; !@raised.nil?; end
    def result; @failure || @raised; end
  private
    def actualize(situation, &block)
      @actual = situation.instance_eval(&block)
      @default_failure = fail("expected true, not #{@actual.inspect}") unless @actual == true
    rescue Failure => e
      @failure = e
    rescue Exception => e
      @raised = Error.new("#{description}: errored with #{e}", e)
    end

    def no_failure_if_default_failure_recorded
      @default_failure = @failure = nil if @default_failure
    end
  end # Assertion
end # Riot