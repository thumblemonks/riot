module Riot
  class Context
    def initialize(description, setups=[], &definition)
      @description = description
      @contexts, @setups, @assertions = [], setups, []
      self.instance_eval(&definition)
    end
    
    def setup(&definition)
      @setups << Setup.new(&definition)
    end

    def asserts(what, &definition)
      (@assertions << Assertion.new("asserts #{what}", &definition)).last
    end

    def context(description, &definition)
      # not liking the dup
      @contexts << Context.new("#{@description} #{description}", @setups.dup, &definition)
    end
    
    def run(reporter)
      runnables = @setups + @assertions
      reporter.describe_context(@description) unless @assertions.empty?
      situation = Situation.new
      runnables.each do |runnable|
        reporter.report(runnable.to_s, runnable.run(situation))
      end
      @contexts.each { |ctx| ctx.run(reporter) }
      reporter
    end
  end # Context
end # Riot
