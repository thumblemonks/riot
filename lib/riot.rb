require 'riot/report'
require 'riot/context'
require 'riot/assertion'
require 'riot/macros'

module Riot

  def self.context(description, reporter = nil, parent = nil, &block)
    reporter ||= self.reporter
    context = Context.new(description, reporter, parent)
    if block_given?
      reporter.time { context.instance_eval(&block) }
      context.report # Results get buffered this way, not necessarily the best
    end
    context
  end

  #
  # Reporter

  def self.reporter; @reporter ||= (Riot.silently? ? NilReport.new : TextReport.new); end
  def self.reporter=(report); @reporter = report; end
  def self.silently!; @silently = true; end
  def self.silently?; @silently || false; end

  def self.report
    reporter.results
    at_exit { exit false unless reporter.passed? }
  end

  at_exit { Riot.report unless Riot.silently? }

  #
  # Exceptions

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
