require 'teststrap'

context "An equals assertion macro" do
  setup do
    Riot::Assertion.new("blue") { "foo" }
  end

  asserts(":pass when expectation met") do
    topic.equals("foo").run(Riot::Situation.new) == [:pass]
  end

  context "that is failing" do
    setup { topic.equals("bar").run(Riot::Situation.new) }

    asserts(":fail") { topic.first == :fail }
    asserts("message") { topic.last == %Q{expected "bar", not "foo"} }
  end # that is failing
end # An equals assertion macro
