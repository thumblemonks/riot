require 'riot/reporter'
require 'riot/context'
require 'riot/situation'
require 'riot/runnable'
require 'riot/assertion'
require 'riot/assertion_macro'

module Riot
  def self.context(description, context_class = Context, &definition)
    root_contexts << context_class.new(description, &definition)
  end

  def self.root_contexts; @root_contexts ||= []; end

  def self.run
    the_reporter = reporter.new
    the_reporter.summarize do
      root_contexts.each { |ctx| ctx.run(the_reporter) }
    end
    the_reporter
  end

  def self.silently!; @silent = true; end
  def self.silently?; defined?(@silent) && @silent == true end

  # This means you don't want Riot to run tests for you. You will run Riot.run manually.
  def self.alone!; @alone = true; end
  def self.alone?; defined?(@alone) && @alone == true end

  def self.reporter=(reporter_class) @reporter_class = reporter_class; end

  def self.reporter
    if Riot.silently?
      Riot::SilentReporter
    else
      (defined?(@reporter_class) && @reporter_class) || Riot::StoryReporter
    end
  end

  # TODO: make this a flag that DotMatrix and Story respect and cause them to print errors/failures
  def self.verbose; Riot.reporter = Riot::VerboseStoryReporter; end
  def self.dots; Riot.reporter = Riot::DotMatrixReporter; end

  at_exit do
    unless Riot.alone?
      exit(run.success?)
    end
  end
end # Riot

class Object
  def context(description, context_class = Riot::Context, &definition)
    Riot.context(description, context_class, &definition)
  end
end
