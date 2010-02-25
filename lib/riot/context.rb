module Riot
  RootContext = Struct.new(:setups, :teardowns, :detailed_description)

  module ContextHelpers
    def assertion_class; Assertion; end
    def situation_class; Situation; end
  end

  # You make your assertions within a Context. The context stores setup and
  # teardown blocks, and allows for nesting and refactoring into helpers.
  class Context
    include ContextHelpers
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
    def setup(&definition)
      (@setups << Setup.new(&definition)).last
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
      "#{parent.detailed_description} #{description}".strip
    end

  private

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
