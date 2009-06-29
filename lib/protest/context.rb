module Protest
  class Context
    attr_reader :assertions, :failures
    def initialize(description, parent=nil)
      @description = description
      @assertions = []
      @failures = []
      @parent = parent
      @setup = nil
      bootstrap(self)
    end

    def bootstrap(binder)
      @parent.bootstrap(binder) if @parent
      binder.instance_eval(&@setup) if @setup
    end

    def to_s
      @to_s ||= [@parent.to_s, @description].join(' ').strip
    end

    def context(description, &block)
      Protest.context(description, self, &block)
    end

    def setup(&block)
      @setup = block
      self.instance_eval(&block)
    end

    def asserts(description, &block) new_assertion(Assertion, description, &block); end
    def denies(description, &block) new_assertion(Denial, description, &block); end

    def run(writer)
      assertions.each do |assertion|
        begin
          assertion.run(self)
          writer.print '.'
        rescue Protest::Failure => e
          writer.print 'F'; @failures << e.asserted(assertion)
        rescue Exception => e
          writer.print 'E'; @failures << Protest::Error.new("errored with #{e}", e).asserted(e)
        end
      end
    end
  private
    def new_assertion(klass, description, &block)
      (assertions << klass.new(description, &block)).last
    end
  end # Context
end # Protest
