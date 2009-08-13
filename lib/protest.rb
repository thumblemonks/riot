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

  def self.context(description, reporter = nil, parent = nil, &block)
    reporter ||= self.reporter
    context = Context.new(description, reporter, parent)
    reporter.time { context.instance_eval(&block) }
    context.report # Results get buffered this way, not necessarily the best
    (contexts << context).last
  end

  def self.dequeue_context(context)
    contexts.delete(context)
  end

  def self.report
    reporter.results
    at_exit { exit false unless reporter.passed? }
  end

  #
  # Reporter
  
  def self.reporter; @reporter ||= TextReport.new; end
  def self.reporter=(report); @reporter = report; end

  #
  # Exception

  class Failure < Exception
    attr_reader :assertion, :context
    def initialize(message, assertion)
      super(message)
      @assertion = assertion
    end

    def contextualize(ctx)
      @context = ctx
      self
    end
    
    def print_stacktrace?; false; end
  end
  class Error < Failure
    def initialize(message, assertion, error)
      super(message, assertion)
      set_backtrace(error.backtrace)
    end
    def print_stacktrace?; true; end
  end
end # Protest

module Kernel
  def context(*args, &block)
    Protest.context(*args, &block)
  end
end # Kernel
