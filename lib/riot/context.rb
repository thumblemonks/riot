module Riot
  RootContext = Struct.new(:setups, :teardowns)
  class Context
    attr_reader :description
    def initialize(description, parent=RootContext.new([],[]), &definition)
      @parent = parent
      @description = description
      @contexts, @setups, @assertions, @teardowns = [], [], [], []
      self.instance_eval(&definition)
    end

    def setups; @parent.setups + @setups; end
    def teardowns; @parent.teardowns + @teardowns; end
    
    def setup(&definition) (@setups << Setup.new(&definition)).last; end
    def teardown(&definition) (@teardowns << Setup.new(&definition)).last; end

    def asserts(what, &definition) new_assertion("asserts", what, &definition); end
    def should(what, &definition) new_assertion("should", what, &definition); end
    def asserts_topic; asserts("topic") { topic }; end

    def context(description, &definition)
      @contexts << self.class.new("#{@description} #{description}", self, &definition)
    end
    
    def run(reporter)
      reporter.describe_context(self) unless @assertions.empty?
      local_run(reporter, Situation.new)
      run_sub_contexts(reporter)
      reporter
    end
  private
    def local_run(reporter, situation)
      (setups + @assertions + teardowns).each do |runnable|
        reporter.report(runnable.to_s, runnable.run(situation))
      end
    end

    def run_sub_contexts(reporter) @contexts.each { |ctx| ctx.run(reporter) }; end

    def new_assertion(scope, what, &definition)
      (@assertions << Assertion.new("#{scope} #{what}", &definition)).last
    end
  end # Context
end # Riot
