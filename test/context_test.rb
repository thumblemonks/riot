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
    a_context = Riot::Context.new("foobar") do
      setup { "foo" }
      setup { topic + "bar" }
      asserts("blah") { topic == "foobar" }
    end
    a_context.run(MockReporter.new)
  end

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
end # Nestings a context

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
