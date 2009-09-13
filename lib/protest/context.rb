module Protest
  class Context
    # The protein
    attr_reader :description, :assertions, :situation, :topic
    def initialize(description, reporter, parent=nil)
      @description, @reporter = description, reporter
      @assertions = []
      @parent = parent
      @situation = Object.new
      bootstrap(@situation)
    end

    def bootstrap(a_situation)
      @parent.bootstrap(a_situation) if @parent # Walk it out
      induce_local_setup(a_situation)
    end

    # something smelly between setup() and bootstrap()
    def setup(&block)
      @setup = block
      @topic = induce_local_setup(situation)
      make_situation_topical
    end

    # DSLee stuff
    def context(description, &block) Protest.context(description, @reporter, self, &block); end
    def asserts(description, &block) new_assertion("asserts #{description}", &block); end
    def should(description, &block) new_assertion("should #{description}", &block); end

    # In conclusion
    def report
      assertions.each do |assertion|
        if assertion.passed?
          @reporter.passed
        else
          result = assertion.result.contextualize(self)
          @reporter.errored(result) if assertion.error?
          @reporter.failed(result) if assertion.failure?
        end
      end
    end

    def to_s; @to_s ||= [@parent.to_s, @description].join(' ').strip; end
  private
    def new_assertion(description, &block)
      (assertions << Assertion.new(description, @situation, &block)).last
    end

    def induce_local_setup(a_situation)
      a_situation.instance_eval(&@setup) if @setup
    end

    def make_situation_topical
      situation.instance_variable_set(:@topic, @topic)
      situation.instance_eval { def topic; @topic; end }
    end
  end # Context
end # Protest
