require 'riot/reporter'
require 'riot/context'
require 'riot/situation'
require 'riot/runnable'
require 'riot/assertion_macros'

module Riot
  def self.context(description, &definition)
    root_contexts << Context.new(description, &definition)
  end

  def self.root_contexts; @root_contexts ||= []; end

  def self.run
    the_reporter = reporter.new
    the_reporter.summarize do
      root_contexts.each { |ctx| ctx.run(the_reporter) }
    end
  end

  def self.silently!; @silent = true; end
  def self.silently?; @silent == true; end

  def self.reporter
    Riot.silently? ? Riot::SilentReporter : (@reporter_class || Riot::StoryReporter)
  end
  def self.reporter=(reporter_class) @reporter_class = reporter_class; end
  def self.dots; Riot.reporter = Riot::DotMatrixReporter; end

  at_exit { run unless Riot.silently? }
end # Riot

class Object
  def context(description, &definition)
    Riot.context(description, &definition)
  end
end
