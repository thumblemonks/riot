module Protest
  class Context
    attr_reader :description, :assertions
    def initialize(description, parent=nil)
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
    def context(description, &block) Protest.context(description, self, &block); end

    def asserts(description, &block) new_assertion(Assertion, description, &block); end
    def denies(description, &block) new_assertion(Denial, description, &block); end

    def run(report)
      assertions.each do |assertion|
        begin
          result = assertion.run(self)
        rescue Protest::Failure => e
          result = e
        rescue Exception => e
          result = Protest::Error.new("errored with #{e}", assertion, e)
        ensure
          report.record self, result
        end
      end
    end
  private
    def new_assertion(klass, description, &block)
      (assertions << klass.new(description, &block)).last
    end
  end # Context
end # Protest
