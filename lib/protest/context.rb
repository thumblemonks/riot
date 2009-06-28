module Protest
  class Context
    attr_reader :assertions
    def initialize(description)
      @_description = description
      @assertions = []
      @failures = []
    end

    def to_s
      @_description
    end

    def setup(&block)
      self.instance_eval(&block)
    end

    def asserts(description, &block)
      (assertions << Assertion.new(description, &block)).last
    end

    def denies(description, &block)
      asserts(description, &block).not
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
  end # Context
end # Protest
