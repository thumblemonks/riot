require 'protest/context'
require 'protest/assertion'

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
    running_time = Time.now - start

    writer.puts "\n\n"
    failures.each_with_index { |failure, idx|
      message = ["##{idx + 1} - #{failure.to_s}"]
      # message += failure.backtrace
      writer.puts message.join("\n") + "\n\n"
    } unless failures.empty?
    assertions = @contexts.inject(0) { |acc, context| acc + context.assertions.length }
    writer.puts "#{@contexts.length} contexts, #{assertions} assertions: #{"%0.6f" % running_time} seconds"
  end
end # Protest

module Kernel
  def context(*args, &block)
    Protest.context(*args, &block)
  end
end # Kernel
