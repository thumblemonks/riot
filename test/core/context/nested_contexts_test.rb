require 'teststrap'

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

context "A context with nested descriptions as classes" do
  setup { Riot::Context.new(String) {}.context(Hash) {} }
  asserts(:description).equals { Hash }
  asserts(:detailed_description).equals("String Hash")
end # A context with nested descriptions as classes
