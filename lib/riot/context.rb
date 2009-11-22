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

    def asserts(what, &definition) new_assertion("asserts", what, &definition); end
    def should(what, &definition) new_assertion("should", what, &definition); end

    def asserts_topic; asserts("topic") { topic }; end

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
  private
    def new_assertion(scope, what, &definition)
      (@assertions << Assertion.new("#{scope} #{what}", &definition)).last
    end
  end # Context
end # Riot
