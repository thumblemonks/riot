require 'teststrap'

# Using == to verify the test because this is the test for :equals itself. Look at assertion_test_passes
# and assertion_test_fails for testing other macros.

context "An equals assertion macro" do
  setup do
    Riot::Assertion.new("blue") { "foo" }
  end

  asserts(":pass when expectation met") do
    topic.equals("foo").run(Riot::Situation.new) == [:pass, %Q{is equal to "foo"}]
  end

  context "that is failing" do
    setup { topic.equals("bar").run(Riot::Situation.new) }

    asserts(":fail") { topic.first == :fail }
    asserts("message") { topic[1] == %Q{expected "bar", not "foo"} }
  end # that is failing

  context "with numeric topic" do
    setup do
      Riot::Assertion.new("blue") { 31415 }
    end

    asserts("failure") do
      topic.equals(30000..32000).run(Riot::Situation.new)[0..1] == [:fail, "expected 30000..32000, not 31415"]
    end
  end # with numeric topic

  context "with block as the expectation" do
    asserts(":pass when block expectation met") do
      topic.equals { "foo" }.run(Riot::Situation.new)
    end.equals([:pass, %Q{is equal to "foo"}])

    asserts(":fail with message when block expectation not met") do
      topic.equals { "bar" }.run(Riot::Situation.new)[0..1]
    end.equals([:fail, %Q{expected "bar", not "foo"}])
  end # with block as the expectation

end # An equals assertion macro
