module Riot
  RootContext = Struct.new(:setups, :teardowns)

  class Context
    attr_reader :description, :parent
    def initialize(description, parent=nil, &definition)
      @parent = parent || RootContext.new([],[])
      @description = description
      @contexts, @setups, @assertions, @teardowns = [], [], [], []
      self.instance_eval(&definition)
    end

    def context(description, &definition)
      new_context(description, self.class, &definition)
    end
    
    def setups; @parent.setups + @setups; end
    def teardowns; @parent.teardowns + @teardowns; end
    
    def setup(&definition) (@setups << Setup.new(&definition)).last; end

    # A setup shortcut that returns the original topic so you don't have to. Good for nested setups. Instead
    # of doing this in your context:
    #
    #   setup do
    #     topic.do_something
    #     topic
    #   end
    #
    # You would do this:
    #
    #   hookup { topic.do_something } # Yay!
    def hookup(&definition)
      setup { self.instance_eval(&definition); topic }
    end

    def teardown(&definition) (@teardowns << Setup.new(&definition)).last; end

    def asserts(what, &definition) new_assertion("asserts", what, &definition); end
    def should(what, &definition) new_assertion("should", what, &definition); end
    def asserts_topic(what="that it"); asserts(what) { topic }; end

    def run(reporter)
      reporter.describe_context(self) unless @assertions.empty?
      local_run(reporter, Situation.new)
      run_sub_contexts(reporter)
      reporter
    end

    def local_run(reporter, situation)
      (setups + @assertions + teardowns).each do |runnable|
        reporter.report(runnable.to_s, runnable.run(situation))
      end
    end

  private

    def run_sub_contexts(reporter) @contexts.each { |ctx| ctx.run(reporter) }; end

    def new_context(description, klass, &definition)
      (@contexts << klass.new("#{@description} #{description}", self, &definition)).last
    end

    def new_assertion(scope, what, &definition)
      if what.kind_of?(Symbol)
        definition ||= lambda { topic.send(what) }
        description = "#{scope} ##{what}"
      else
        description = "#{scope} #{what}"
      end

      (@assertions << Assertion.new(description, &definition)).last
    end
  end # Context
end # Riot
