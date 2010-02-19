require 'teststrap'

context "Reporting a context" do
  setup do
    a_context = Riot::Context.new("foobar") do
      asserts("passing") { true }
      asserts("failing") { false }
      asserts("erroring") { raise Exception }
    end
    a_context.run(MockReporter.new)
  end

  asserts("one passed test") { topic.passes == 1 }
  asserts("one failed test") { topic.failures == 1 }
  asserts("one errored test") { topic.errors == 1 }
end # Reporting a context

context "Defining a context with multiple setups" do
  setup do
    @a_context = Riot::Context.new("foobar") do
      setup { "foo" }
      setup { topic + "bar" }
      asserts("blah") { topic == "foobar" }
    end
    @a_context.run(MockReporter.new)
  end
  asserts("has setups") { @a_context.setups.size }.equals(2)
  asserts("all tests pass") { topic.passes == 1 }
end # Defining a context with multiple setups

context "Nesting a context" do
  setup do
    a_context = Riot::Context.new("foobar") do
      asserts("passing") { true }
      context "bazboo" do
        asserts("passing") { true }
        asserts("failing") { false }
        asserts("erroring") { raise Exception }
      end
    end
    a_context.run(MockReporter.new)
  end

  asserts("one passed test") { topic.passes == 2 }
  asserts("one failed test") { topic.failures == 1 }
  asserts("one errored test") { topic.errors == 1 }

  context "with setups" do
    setup do
      a_context = Riot::Context.new("foobar") do
        setup { "foo" }
        context "bazboo" do
          setup { topic + "bar" }
          asserts("passing") { topic == "foobar" }
        end
      end
      a_context.run(MockReporter.new)
    end

    asserts("parent setups are called") { topic.passes == 1 }
  end # with setups
end # Nesting a context

context "Using should" do
  setup do
    a_context = Riot::Context.new("foobar") do
      should("pass") { true }
      should("fail") { false }
      should("error") { raise Exception }
    end
    a_context.run(MockReporter.new)
  end

  asserts("one passed test") { topic.passes == 1 }
  asserts("one failed test") { topic.failures == 1 }
  asserts("one errored test") { topic.errors == 1 }
end # Using should

context "The asserts_topic shortcut" do
  setup do
    Riot::Context.new("foo") {}.asserts_topic
  end

  should("return an Assertion") { topic }.kind_of(Riot::Assertion)

  should("return the actual topic as the result of evaling the assertion") do
    (situation = Riot::Situation.new).instance_variable_set(:@_topic, "bar")
    topic.equals("bar").run(situation)
  end.equals([:pass, %Q{is equal to "bar"}])

  asserts(:to_s).equals("asserts that it")

  context "with an explicit description" do
    setup { Riot::Context.new("foo") {}.asserts_topic("get some") }
    asserts(:to_s).equals("asserts get some")
  end
end # The asserts_topic shortcut

context "Using a hookup" do
  setup do
    situation = Riot::Situation.new
    a_context = Riot::Context.new("foobar") {}
    a_context.setup { "I'm a string" }.run(situation)
    a_context.hookup { topic.size }.run(situation)
    situation.topic
  end
  
  asserts_topic.equals("I'm a string")
end # Using a hookup

context "Making a new context" do
  asserts("RootContext is used if nil parent is provided") do
    Riot::Context.new("hello", nil) {}.parent
  end.kind_of(Riot::RootContext)
end # Making a context

context "A context with a helper" do
  setup { "foo" }

  helper(:upcase) { topic.upcase }
  helper(:append) {|str| topic + str }

  asserts("executing the helper") { upcase }.equals("FOO")
  asserts("calling a helper with an argument") { append("bar") }.equals("foobar")
end
