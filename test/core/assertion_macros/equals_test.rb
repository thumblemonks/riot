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

context "A negative equals assertion macro" do
  setup do
    Riot::Assertion.new("that flirgy", true) { "foo" }
  end

  asserts(":pass when values do not match") do
    topic.equals("bar").run(Riot::Situation.new) == [:pass, %Q{is equal to "bar" when it is "foo"}]
  end

  asserts(":fail when values do match") do
    topic.equals("foo").run(Riot::Situation.new)[0..1] == [:fail, %Q{did not expect "foo"}]
  end
  
  asserts("result of evaluating when number outside of range") do
    Riot::Assertion.new("blue", true) { 31415 }.equals(30000..32000).run(Riot::Situation.new)
  end.equals([:pass, "is equal to 30000..32000 when it is 31415"])
  
  context "with block as the expectation" do
    asserts(":pass when block expectation values do not equal") do
      topic.equals { "bazzle" }.run(Riot::Situation.new)
    end.equals([:pass, %Q{is equal to "bazzle" when it is "foo"}])
  
    asserts(":fail with message when block expectation values do equal") do
      topic.equals { "foo" }.run(Riot::Situation.new)[0..1]
    end.equals([:fail, %Q{did not expect "foo"}])
  end # with block as the expectation

end # A negative assertion macro
