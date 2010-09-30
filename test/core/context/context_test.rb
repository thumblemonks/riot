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

context "Making a new context" do
  asserts("RootContext is used if nil parent is provided") do
    Riot::Context.new("hello", nil) {}.parent
  end.kind_of(Riot::RootContext)
end # Making a context
