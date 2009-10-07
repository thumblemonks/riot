module Riot

  class Assertion
    attr_reader :raised, :to_s, :description, :situation
    def initialize(description, situation, &block)
      @description = @to_s = description
      @situation = situation
      actualize(situation, &block)
    end

    def actual
      @default_failure = @failure = nil if @default_failure
      @actual
    end

    def fail(message)
      @failure = Failure.new("#{description}: #{message}") unless errored?
    end

    def failed?; !@failure.nil?; end
    def errored?; !@raised.nil?; end
    def passed?; !(failed? || errored?); end
    def result; @failure || error; end
  private
    def actualize(situation, &block)
      @actual = situation.instance_eval(&block)
      @default_failure = fail("expected true, not #{@actual.inspect}") unless @actual == true
    rescue Failure => e
      @failure = e
    rescue Exception => e
      @raised = e
    end

    def error
      Error.new("#{description}: errored with #{@raised}", @raised) if errored?
    end
  end # Assertion
end # Riot