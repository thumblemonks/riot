require 'protest/context'
require 'protest/assertion'
require 'protest/macros'

module Protest
  def self.contexts
    @contexts ||= []
  end

  def self.context(description, parent = nil, &block)
    context = Context.new(description, parent)
    context.instance_eval(&block)
    (contexts << context).last
  end

  def self.dequeue_context(context)
    contexts.delete(context)
  end

  def self.run(writer=nil)
    writer ||= STDOUT
    start = Time.now
    failures = @contexts.map { |context| context.run(writer) }.flatten.compact
    running_time = Time.now - start

    writer.puts "\n\n"
    counter = 0
    @contexts.each do |context|
      context.failures.each do |failure|
        counter += 1
        message = ["##{counter} - #{context} asserted #{failure}"]
        message += failure.backtrace
        writer.puts message.join("\n") + "\n\n"
      end
    end
    assertions = @contexts.inject(0) { |acc, context| acc + context.assertions.length }
    writer.puts "#{@contexts.length} contexts, #{assertions} assertions: #{"%0.6f" % running_time} seconds"
  end

  #
  # Failures

  class Failure < Exception
    def asserted(assertion)
      @assertion = assertion
      self
    end
    
    def to_s; "#{@assertion}: #{super}"; end
  end
  class Error < Failure
    def initialize(message, e)
      super(message)
      set_backtrace(e.backtrace)
    end
  end
end # Protest

module Kernel
  def context(*args, &block)
    Protest.context(*args, &block)
  end
end # Kernel
