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
    reporter = Riot::StoryReporter.new
    reporter.summarize do
      root_contexts.each { |ctx| ctx.run(reporter) }
    end
  end

  at_exit do
    run
  end
end # Riot

class Object
  def context(description, &definition)
    Riot.context(description, &definition)
  end
end
