require 'teststrap'

# Using == to verify the test because this is the test for :equals itself. Look at assertion_test_passes
# and assertion_test_fails for testing other macros.

context "An equivalent_to assertion macro" do
  setup { Riot::Assertion.new("red") { "what" } }

  asserts("String is equivalent to 'what'") do
    topic.equivalent_to(String).run(Riot::Situation.new)
  end.equals([:pass, "is equivalent to String"])

  asserts("an array is not equivalent to 'what'") do
    topic.equivalent_to([]).run(Riot::Situation.new)[0..1]
  end.equals([:fail, 'expected "what" to be equivalent to []'])

  context "with numeric topic" do
    setup { Riot::Assertion.new("blue") { 31413 } }

    asserts(":pass when in expected range") do
      topic.equivalent_to(30000..32000).run(Riot::Situation.new)
    end.equals([:pass, "is equivalent to 30000..32000"])

    asserts ":fail when not in expected range" do 
      topic.equivalent_to(32000..33000).run(Riot::Situation.new)[0..1]
    end.equals([:fail, 'expected 31413 to be equivalent to 32000..33000'])

  end # with numeric topic

end # An equivalent_to assertion macro

context "A negative equivalent_to assertion macro" do
  setup { Riot::Assertion.new("red", true) { "what" } }
  
  asserts("String is not equivalent to 'what'") do
    topic.equivalent_to(String).run(Riot::Situation.new)[0..1]
  end.equals([:fail, 'expected "what" not to be equivalent to String'])

  asserts("an array is not equivalent to 'what'") do
    topic.equivalent_to([]).run(Riot::Situation.new)
  end.equals([:pass, "is not equivalent to []"])

  context "with numeric topic" do
    setup { Riot::Assertion.new("blue", true) { 31413 } }

    asserts(":fail when not in expected range") do
      topic.equivalent_to(30000..32000).run(Riot::Situation.new)[0..1]
    end.equals([:fail, "expected 31413 not to be equivalent to 30000..32000"])

    asserts ":pass when in expected range" do 
      topic.equivalent_to(32000..33000).run(Riot::Situation.new)
    end.equals([:pass, "is not equivalent to 32000..33000"])
    
  end # with numeric topic
end # A negative equivalent_to assertion macro