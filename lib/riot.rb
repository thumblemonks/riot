require 'riot/errors'
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

  at_exit do
    Riot.reporter.results
    exit false unless reporter.passed?
  end unless Riot.silently?
end # Riot

module Kernel
  def context(*args, &block)
    Riot.context(*args, &block)
  end
end # Kernel
