module Protest
  class Context
    # The protein
    attr_reader :description, :assertions
    def initialize(description, reporter, parent=nil)
      @reporter = reporter
      @description = description
      @assertions = []
      @parent = parent
      @setup = nil
      bootstrap(self)
    end

    def bootstrap(binder)
      @parent.bootstrap(binder) if @parent
      binder.instance_eval(&@setup) if @setup
    end

    def setup(&block)
      @setup = block
      self.instance_eval(&block)
    end

    def to_s; @to_s ||= [@parent.to_s, @description].join(' ').strip; end

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
  private
    def new_assertion(description, &block)
      (assertions << Assertion.new(description, self, &block)).last
    end
  end # Context
end # Protest
