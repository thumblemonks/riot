require 'riot/context_options'
require 'riot/context_helpers'

module Riot
  RootContext = Struct.new(:setups, :teardowns, :detailed_description, :option_set)

  # Defines the classes {Riot::Context} will use when creating new assertions and situations.
  module ContextClassOverrides
    # Returns the default class used for generating new {Riot::Assertion Assertion} instances. Defaults to
    # {Riot::Assertion}.
    #
    # @return [Class]
    def assertion_class; Assertion; end

    # Returns the default class used for generating new {Riot::Situation Situation} instances. Defaults to
    # {Riot::Situation}.
    #
    # @return [Class]
    def situation_class; Situation; end
  end # ContextClassOverrides

  # An {Riot::Assertion} is declared within a Context. The context stores setup and teardown
  # blocks, and allows for nesting and refactoring. Extension developers may also configure
  # {Riot::ContextMiddleware Middleware} objects in order to extend the functionality of a Context.
  class Context
    include ContextClassOverrides
    include ContextOptions
    include ContextHelpers

    # The set of middleware helpers configured for the current test space.
    #
    # @return [Array<Riot::ContextMiddleware>]
    def self.middlewares; @middlewares ||= []; end

    # The partial description of just this context.
    #
    # @return [String]
    attr_reader :description

    # The parent context.
    #
    # @return [Riot::Context, nil] a context or nil
    attr_reader :parent

    # Creates a new Context
    #
    # @param [String] description a partial description of this context
    # @param [Riot::Context, nil] parent a parent context or nothing
    # @param [lambda] definition the body of this context
    def initialize(description, parent=nil, &definition)
      @parent = parent || RootContext.new([],[], "", {})
      @description = description
      @contexts, @setups, @assertions, @teardowns = [], [], [], []
      @context_error = nil
      @options = @parent.option_set.dup
      prepare_middleware(&definition)
    rescue Exception => e
      @context_error = e
    end

    # Create a new test context.
    #
    # @param [String] description
    # @return [Riot::Context] the newly created context
    def context(description, &definition)
      new_context(description, self.class, &definition)
    end
    alias_method :describe, :context

    # @private
    # Returns an ordered list of the setup blocks for the context.
    #
    # @return [Array<Riot::RunnableBlock>]
    def setups
      @parent.setups + @setups
    end

    # @private
    # Returns an ordered list of the teardown blocks for the context.
    #
    # @return [Array<Riot::RunnableBlock>]
    def teardowns
      @parent.teardowns + @teardowns
    end

    # Executes the setups, hookups, assertions, and teardowns and passes results on to a given
    # {Riot::Reporter Reporter}. Sub-contexts will also be executed and provided the given reporter. A new
    # {Riot::Situation Situation} will be created from the specified {#situation_class Situation class}.
    #
    # @param [Riot::Reporter] reporter the reporter to report results to
    # @return [Riot::Reporter] the given reporter
    def run(reporter)
      reporter.describe_context(self) unless @assertions.empty?
      if @context_error
        reporter.report("context preparation", [:context_error, @context_error])
      else
        local_run(reporter, situation_class.new)
        run_sub_contexts(reporter)
      end
      reporter
    end

    # @private
    # Used mostly for testing purposes; this method does the actual running of just this context.
    # @param [Riot::Reporter] reporter the reporter to report results to
    # @param [Riot::Situation] situation the situation to use for executing the context.
    def local_run(reporter, situation)
      runnables.each do |runnable|
        code, response = *runnable.run(situation)
        reporter.report(runnable.to_s, [code, response])
        break if code == :setup_error
      end
    end

    # Prints the full description from the context tree, grabbing the description from the parent and
    # appending the description given to this context.
    #
    # @return [String] the full description for this context
    def detailed_description
      "#{parent.detailed_description} #{description}".strip
    end

  private

    # Iterate over the registered middlewares and let them configure this context instance if they so
    # choose. {Riot::AllImportantMiddleware} will always be the last in the chain.
    def prepare_middleware(&context_definition)
      last_middleware = AllImportantMiddleware.new(&context_definition)
      Context.middlewares.inject(last_middleware) do |previous_middleware, middleware|
        middleware.new(previous_middleware)
      end.call(self)
    end

    # The collection of things that are {Riot::RunnableBlock} instances in this context.
    #
    # @return [Array<Riot::RunnableBlock>]
    def runnables
      setups + @assertions + teardowns
    end

    # Execute each sub context.
    #
    # @param [Riot::Reporter] reporter the reporter instance to use
    # @return [nil]
    def run_sub_contexts(reporter)
      @contexts.each { |ctx| ctx.run(reporter) }
    end

    # Creates a new context instance and appends it to the set of immediate children sub-contexts.
    #
    # @param [String] description a partial description
    # @param [Class] klass the context class that a sub-context will be generated from
    # @param [lambda] definition the body of the sub-context
    # @return [#run] something that hopefully responds to run and is context-like
    def new_context(description, klass, &definition)
      (@contexts << klass.new(description, self, &definition)).last
    end

  end # Context
end # Riot
