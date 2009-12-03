module Riot
  RootContext = Struct.new(:setups, :teardowns)
  class Context
    def initialize(description, parent=RootContext.new([],[]), &definition)
      @parent = parent
      @description = description
      @contexts, @setups, @assertions, @teardowns = [], [], [], []
      self.instance_eval(&definition)
    end
    
    def setup(&definition)
      @setups << Setup.new(&definition)
    end
    
    def teardown(&definition)
      @teardowns << Setup.new(&definition)
    end
    
    def teardowns
      @parent.teardowns + @teardowns
    end

    def setups
      @parent.setups + @setups
    end

    def asserts(what, &definition) new_assertion("asserts", what, &definition); end
    def should(what, &definition) new_assertion("should", what, &definition); end

    def asserts_topic; asserts("topic") { topic }; end

    def context(description, &definition)
      @contexts << Context.new("#{@description} #{description}", self, &definition)
    end
    
    def run(reporter)
      runnables = setups + @assertions + teardowns
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
