module Riot
  class Situation
    def fail(message)
      raise Failure.new(message)
    end
  end

  class Context
    # The protein
    attr_reader :description, :assertions, :situation
    def initialize(description, reporter, parent=nil, &block)
      @description, @reporter, @parent = description, reporter, parent
      @assertions = []
      @situation = Situation.new
      bootstrap(@situation)
      instance_eval(&block) if block_given? # running the context
      report
    end

    def bootstrap(a_situation)
      @parent.bootstrap(a_situation) if @parent # Walk it out
      induce_local_setup(a_situation)
    end

    # something smelly between setup() and bootstrap()
    def setup(&block)
      @setup = block
      make_situation_topical(induce_local_setup(situation))
    end

    # DSLee stuff
    def context(description, &block) Context.new(description, @reporter, self, &block); end
    def asserts(description, &block) new_assertion("asserts #{description}", &block); end
    def should(description, &block) new_assertion("should #{description}", &block); end

    def report
      assertions.each { |assertion| @reporter.process_assertion(assertion) }
    end

    def to_s; @to_s ||= [@parent.to_s, @description].join(' ').strip; end
  private
    def new_assertion(description, &block)
      assertion = Assertion.new("#{to_s} #{description}", @situation, &block)
      assertions << assertion
      assertion
    end

    def induce_local_setup(a_situation)
      a_situation.instance_eval(&@setup) if @setup
    end

    def make_situation_topical(topic)
      situation.instance_variable_set(:@topic, topic)
      situation.instance_eval { def topic; @topic; end }
    end
  end # Context
end # Riot
