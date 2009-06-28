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

  def self.run(writer=nil)
    writer ||= STDOUT
    start = Time.now
    failures = @contexts.map { |context| context.run(writer) }.flatten
    STDOUT.puts ''
    running_time = Time.now - start
    failures.each_with_index { |failure, idx|
      message = ["##{idx + 1} - #{failure.to_s}"]
      # message += failure.backtrace
      STDOUT.puts message.join("\n")
    } unless failures.empty?
    STDOUT.puts "\n#{@contexts.length} contexts: #{"%0.6f" % running_time} seconds"
  end

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
