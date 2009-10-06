require 'riot/report'
require 'riot/context'
require 'riot/assertion'
require 'riot/macros'

module Riot
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
  def self.silently!; @silently = true; end
  def self.silently?; @silently || false; end

  #
  # Exception

  class Failure < Exception
    attr_accessor :assertion, :context
    def initialize(message, assertion=nil)
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
end # Riot

module Kernel
  def context(*args, &block)
    Riot.context(*args, &block)
  end
end # Kernel
