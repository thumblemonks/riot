require 'teststrap'

context "An includes assertion macro" do
  setup do
    Riot::Assertion.new("an array") { [1, 6, 42, 7] }
  end

  asserts(":pass when expectation met") do
    topic.includes(42).run(Riot::Situation.new) == [:pass]
  end

  context "that is failing" do
    setup { topic.includes(99).run(Riot::Situation.new) }

    asserts(":fail") { topic.first == :fail }
    asserts("message") { topic.last == %Q{expected [1, 6, 42, 7] to include 99} }
  end # that is failing
end # An includes assertion macro
