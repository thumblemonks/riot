module Riot
  module ContextHelpers

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
    #
    # @param [Boolean] premium indicates importance of the setup
    # @return [Riot::Setup]
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
    #
    # @param [String, Symbol] name the name of the helper
    # @return [Riot::Helper]
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
    #
    # @return [Riot::Setup]
    def hookup(&definition)
      setup { self.instance_eval(&definition); topic }
    end

    # Add a teardown block. You may define multiple of these as well.
    #
    #  teardown { Bombs.drop! }
    #
    # @return [Riot::Setup]
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
    # @param [String, Symbol] what description of test or property to inspect on the topic
    # @return [Riot::Assertion]
    def asserts(what, &definition)
      new_assertion("asserts", what, &definition)
    end

    # Same as #asserts, except it uses the phrase "should" in the report output. Sometimes you feel like a
    # nut, sometimes you don't.
    #
    #   should("ensure expected") { "bar" }.equals("bar")
    #
    # @param [String, Symbol] what description of test or property to inspect on the topic
    # @return [Riot::Assertion]
    def should(what, &definition)
      new_assertion("should", what, &definition)
    end

    # Like an assertion, but expects negative results.
    #
    # In the most basic form, a denial requires a descriptive name and a block.
    #
    #   denies("#size is equals to 2") { topic.size != 2 }
    #
    # Several shortcuts are available here as well. Assertion macros can be added to the
    # end, automating a number of common assertion patterns, e.g.
    #
    #   denies("#size") { topic.size }.equals(2)
    #
    # Furthermore, the pattern of testing an attribute on the topic is codified as
    #
    #   denies(:size).equals(2)
    #
    # Passing a Symbol to +denies+ enables this behaviour. For more information on
    # assertion macros, see {Riot::AssertionMacro}.
    #
    # @param [String, Symbol] what description of test or property to inspect on the topic
    # @return [Riot::Assertion]
    def denies(what, &definition)
      new_assertion("denies", what, true, &definition)
    end

    # Makes an assertion on the topic itself, e.g.
    #
    #   asserts_topic.matches(/^ab+/)
    #
    # @param [String] what description of test
    # @return [Riot::Assertion]
    def asserts_topic(what="that it")
      asserts(what) { topic }
    end
  private
    def new_assertion(scope, what, negative=false, &definition)
      if what.kind_of?(Symbol)
        definition ||= proc { topic.send(what) }
        description = "#{scope} ##{what}"
      elsif what.kind_of?(Array)
        definition ||= proc { topic.send(*what) }
        description = "#{scope} ##{what.shift} with argument(s): #{what}"
      else
        description = "#{scope} #{what}"
      end

      (@assertions << assertion_class.new(description, negative, &definition)).last
    end
  end # AssertionHelpers
end # Riot
