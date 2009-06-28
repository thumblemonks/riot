module Protest
  class Context
    attr_reader :assertions
    def initialize(description, parent=nil)
      @description = description
      @assertions = []
      @failures = []
      @parent = parent
      @setup = nil
    end

    def to_s
      @description
    end

    def context(description, &block)
      Protest.context(description, self, &block)
    end

    def setup(&block)
      @setup = block
      self.bootstrap(self)
    end

    def asserts(description, &block)
      (assertions << Assertion.new(description, &block)).last
    end

    def run(writer)
      assertions.each do |assertion|
        begin
          assertion.run(self)
          writer.print '.'
        rescue Protest::Failure => e
          writer.print 'F'
          @failures << e
        end
      end
      @failures
    end

    def bootstrap(binder)
      @parent.bootstrap(binder) if @parent
      binder.instance_eval(&@setup) if @setup
    end
  end # Context
end # Protest
