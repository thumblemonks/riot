module Riot
  class Context
    # The protein
    attr_reader :description, :assertions, :situation
    def initialize(description, reporter, parent=nil, &context_block)
      @description, @reporter, @parent = description, reporter, parent
      @setups, @assertions = [], []
      @situation = Situation.new
      bootstrap(@situation)
      instance_eval(&context_block) if block_given? # running the context
      report
    end

    # Walk it out. Call setup from parent first
    def bootstrap(a_situation)
      @parent.bootstrap(a_situation).each do |setup_block|
        run_setup(a_situation, &setup_block)
      end if @parent
      @setups
    end

    def report
      assertions.each { |assertion| @reporter.process_assertion(assertion) }
    end

    def to_s; @to_s ||= [@parent.to_s, @description].join(' ').strip; end

    # DSLee stuff

    def setup(&block)
      @setups << block
      run_setup(situation, &block)
    end

    def context(description, &block) Context.new(description, @reporter, self, &block); end
    def asserts(what, &block) add_assertion("asserts #{what}", &block); end
    def should(what, &block) add_assertion("should #{what}", &block); end
    def topic; asserts("topic") { topic }; end
  private
    def add_assertion(what, &block)
      (assertions << Assertion.new("#{to_s} #{what}", @situation, &block)).last
    end

    def run_setup(a_situation, &setup_block)
      a_situation.topic = a_situation.instance_eval(&setup_block) if setup_block
    end
  end # Context
end # Riot
