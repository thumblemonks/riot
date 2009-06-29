require 'protest/report'
require 'protest/context'
require 'protest/assertion'
require 'protest/macros'

module Protest
  #
  # Initializing logic
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

  def self.run(report=nil)
    report ||= TextReport.new
    report.start
    @contexts.each { |context| context.run(report) }
    report.stop
    report.results
    at_exit { exit false unless report.passed? }
  end

  #
  # Exception

  class Failure < Exception
    attr_reader :assertion
    def initialize(message, assertion)
      super(message)
      @assertion = assertion
    end
  end
  class Error < Failure
    def initialize(message, assertion, e)
      super(message, assertion)
      set_backtrace(e.backtrace)
    end
  end
end # Protest

module Kernel
  def context(*args, &block)
    Protest.context(*args, &block)
  end
end # Kernel
