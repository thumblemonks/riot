require 'teststrap'

# Using == to verify the test because this is the test for :equals itself. Look at assertion_test_passes
# and assertion_test_fails for testing other macros.

context "An equivalent_to assertion macro" do
  setup do
    Riot::Assertion.new("red") { "what" }
  end

  asserts("String is equivalent to 'what'") do
    topic.equivalent_to(String).run(Riot::Situation.new) == [:pass, %Q{is equivalent to String}]
  end

  asserts("an array is not equivalent to 'what'") do
    topic.equivalent_to([]).run(Riot::Situation.new) == [:fail, %Q{expected "what" to be equivalent to []}]
  end

  context "with numeric topic" do
    setup do
      Riot::Assertion.new("blue") { 31413 }
    end

    asserts(":pass when in expected range") do
      topic.equivalent_to(30000..32000).run(Riot::Situation.new) == [:pass, "is equivalent to 30000..32000"]
    end

    context "when not in expected range" do
      setup { topic.equivalent_to(32000..33000).run(Riot::Situation.new) }

      asserts(":fail") { topic.first == :fail }
      asserts("message") { topic.last == %Q{expected 31413 to be equivalent to 32000..33000} }
    end
  end # with numeric topic

end # An equivalent_to assertion macro
