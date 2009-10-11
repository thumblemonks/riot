require 'riot/errors'
require 'riot/report'
require 'riot/situation'
require 'riot/context'
require 'riot/assertion'
require 'riot/assertion_macros'

module Riot

  # Configuration

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
  def context(description, reporter = nil, parent = nil, &block)
    reporter ||= Riot.reporter
    reporter.time { Riot::Context.new(description, reporter, parent, &block) }
  end
end # Kernel
