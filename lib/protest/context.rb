module Protest
  def self.context(description, &block)
    @contexts ||= []
    context = Context.new(description)
    context.instance_eval(&block)
    (@contexts << context).last
  end

  def self.dequeue_context(context)
    @contexts.delete(context)
  end

  def self.run
    failures = @contexts.map { |context| context.run }.flatten
    STDOUT.puts ''
    STDOUT.puts failures.map { |failure|
      message = [failure.to_s]
      # message += failure.backtrace
      message.join("\n")
    }.join("\n\n") unless failures.empty?
  end

  class Context
    attr_reader :assertions
    def initialize(description)
      @_description = description
      @assertions = []
      @failures = []
    end

    def setup(&block)
      self.instance_eval(&block)
    end

    def asserts(description, &block)
      (assertions << Assertion.new(description, true, &block)).last
    end

    def run(writer=nil)
      writer ||= STDOUT
      assertions.each do |assertion|
        begin
          assertion.run(self)
          writer.print '.'
        rescue TeaTime::Failure => e
          writer.print 'F'
          @failures << e
        end
      end
      @failures
    end
  end # Context
end # Protest
