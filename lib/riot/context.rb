module Riot
  RootContext = Struct.new(:setups, :teardowns, :detailed_description)

  class ContextMiddleware
    # Registers the current middleware class with Riot so that it may be included in the set of middlewares
    # Riot will poke before executing a Context.
    #
    #   class MyContextMiddleware < Riot::ContextMiddleware
    #     register
    #     def handle?(context); ...; end
    #     def prepare(context); ...; end
    #   end
    def self.register; Context.middlewares << self.new; end

    # Called prior to a Context being executed. If this method returns true, +call+ will be called. This
    # methods expects to receive an instance of the Context to be executed. Generally, you will inspect
    # various aspects of the Context to determine if this middleware is meant to be used.
    def handle?(context); false; end

    # The meat of the middleware. Because you have access to the Context, you can add your own setups,
    # hookups, etc. +call+ will be called before any tests are run, but after the Context is configured.
    def call(context); end
  end

  module ContextClassOverrides
    def assertion_class; Assertion; end
    def situation_class; Situation; end
  end

  module ContextOptions
    # Set options for the specific context. These options will generally be used for context middleware.
    # Riot::Context does not currently look at any options.
    #
    #   context "Foo" do
    #     set :transactional, true
    #   end
    def set(key, value) options[key] = value; end

    # Returns the value of a set option. The key must match exactly, symbols and strings are not
    # interchangeable.
    #
    # @return [Object]
    def option(key) options[key]; end
  private
    def options; @options ||= {}; end
  end

  # You make your assertions within a Context. The context stores setup and teardown blocks, and allows for
  # nesting and refactoring into helpers. Extension developers may also configure ContextMiddleware objects
  # in order to extend the functionality of a Context.
  class Context
    include ContextClassOverrides
    include ContextOptions

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
      @parent = parent || RootContext.new([],[], "")
      @description = description
      @contexts, @setups, @assertions, @teardowns = [], [], [], []
      self.instance_eval(&definition)
      prepare_middleware
    end

    # Create a new test context.
    #
    # @param [String] description
    def context(description, &definition)
      new_context(description, self.class, &definition)
    end

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
    
    # Add a setup block.
    #
    # A setup block defines the topic of the context. There can be multiple setup
    # blocks; each can access the previous topic through the +topic+ attribute.
    #
    #   context "A string" do
    #     setup { "foo" }
    #     setup { topic * 2 }
    #     asserts(:length).equals(6)
    #   end
    #
    # If you provide +true+ as the first argument, the setup will be unshifted onto the list of setups,
    # ensuring it will be run before any other setups. This is really only useful for context middlewares.
    def setup(premium=false, &definition)
      setup = Setup.new(&definition)
      premium ? @setups.unshift(setup) : @setups.push(setup)
      setup
    end

    # Helpers are essentially methods accessible within a situation.
    #
    # They're not setup methods, but can be called from setups or from assetions. Each time called, the
    # helper will be evaluated. It's not currently memoized.
    #
    #   context "A string" do
    #     helper(:foo) { "bar" }
    #     asserts("a foo") { foo }.equals("bar")
    #   end
    def helper(name, &block)
      (@setups << Helper.new(name, &block)).last
    end

    # A setup shortcut that returns the original topic so you don't have to. Good for nested setups. Instead
    # of doing this in your context:
    #
    #   setup do
    #     topic.do_something
    #     topic
    #   end
    #
    # You would do this:
    #
    #   hookup { topic.do_something } # Yay!
    def hookup(&definition)
      setup { self.instance_eval(&definition); topic }
    end

    # Add a teardown block.
    def teardown(&definition)
      (@teardowns << Setup.new(&definition)).last
    end

    # Makes an assertion.
    #
    # In the most basic form, an assertion requires a descriptive name and a block.
    #
    #   asserts("#size is equals to 2") { topic.size == 2 }
    #
    # However, several shortcuts are available. Assertion macros can be added to the
    # end, automating a number of common assertion patterns, e.g.
    #
    #   asserts("#size") { topic.size }.equals(2)
    #
    # Furthermore, the pattern of testing an attribute on the topic is codified as
    #
    #   asserts(:size).equals(2)
    #
    # Passing a Symbol to +asserts+ enables this behaviour. For more information on
    # assertion macros, see {Riot::AssertionMacro}.
    #
    # @param [String, Symbol] what the property being tested
    def asserts(what, &definition)
      new_assertion("asserts", what, &definition)
    end

    def should(what, &definition)
      new_assertion("should", what, &definition)
    end

    # Makes an assertion on the topic itself, e.g.
    #
    #   asserts_topic.matches(/^ab+/)
    def asserts_topic(what="that it")
      asserts(what) { topic }
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

    def detailed_description
      # d = @description.kind_of?(Class) ? @description.name : @description
      "#{parent.detailed_description} #{description}".strip
    end

  private

    def prepare_middleware
      Context.middlewares.each { |middleware| middleware.call(self) if middleware.handle?(self) }
    end

    def runnables
      setups + @assertions + teardowns
    end

    def run_sub_contexts(reporter) @contexts.each { |ctx| ctx.run(reporter) }; end

    def new_context(description, klass, &definition)
      (@contexts << klass.new(description, self, &definition)).last
    end

    def new_assertion(scope, what, &definition)
      if what.kind_of?(Symbol)
        definition ||= lambda { topic.send(what) }
        description = "#{scope} ##{what}"
      else
        description = "#{scope} #{what}"
      end

      (@assertions << assertion_class.new(description, &definition)).last
    end
  end # Context
end # Riot
