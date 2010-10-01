require 'riot/context_options'
require 'riot/context_helpers'

module Riot
  RootContext = Struct.new(:setups, :teardowns, :detailed_description, :options)

  module ContextClassOverrides
    def assertion_class; Assertion; end
    def situation_class; Situation; end
  end # ContextClassOverrides

  # You make your assertions within a Context. The context stores setup and teardown blocks, and allows for
  # nesting and refactoring into helpers. Extension developers may also configure ContextMiddleware objects
  # in order to extend the functionality of a Context.
  class Context
    include ContextClassOverrides
    include ContextOptions
    include ContextHelpers

    # The set of middleware helpers configured for the current test space.
    #
    # @return [Array]
    def self.middlewares; @middlewares ||= []; end

    # The description of the context.
    #
    # @return [String]
    attr_reader :description

    # The parent context.
    #
    # @return [Riot::Context]
    attr_reader :parent

    def initialize(description, parent=nil, &definition)
      @parent = parent || RootContext.new([],[], "", {})
      @description = description
      @contexts, @setups, @assertions, @teardowns = [], [], [], []
      @options = @parent.options
      prepare_middleware(&definition)
    end

    # Create a new test context.
    #
    # @param [String] description
    def context(description, &definition)
      new_context(description, self.class, &definition)
    end
    alias_method :describe, :context

    # Returns an ordered list of the setup blocks for the context.
    #
    # @return [Array[Riot::RunnableBlock]]
    def setups
      @parent.setups + @setups
    end

    # Returns an ordered list of the teardown blocks for the context.
    #
    # @return [Array[Riot::RunnableBlock]]
    def teardowns
      @parent.teardowns + @teardowns
    end

    def run(reporter)
      reporter.describe_context(self) unless @assertions.empty?
      local_run(reporter, situation_class.new)
      run_sub_contexts(reporter)
      reporter
    end

    def local_run(reporter, situation)
      runnables.each { |runnable| reporter.report(runnable.to_s, runnable.run(situation)) }
    end

    # Prints the full description from the context tree
    def detailed_description
      "#{parent.detailed_description} #{description}".strip
    end

  private

    def prepare_middleware(&context_definition)
      last_middleware = AllImportantMiddleware.new(&context_definition)
      Context.middlewares.inject(last_middleware) do |last_middleware, middleware|
        middleware.new(last_middleware)
      end.call(self)
    end

    def runnables
      setups + @assertions + teardowns
    end

    def run_sub_contexts(reporter) @contexts.each { |ctx| ctx.run(reporter) }; end

    def new_context(description, klass, &definition)
      (@contexts << klass.new(description, self, &definition)).last
    end

  end # Context
end # Riot
