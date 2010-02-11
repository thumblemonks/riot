require 'teststrap'

context "An includes assertion macro" do
  setup do
    Riot::Assertion.new("an array") { [1, 6, 42, 7] }
  end

  assertion_test_passes("when array includes 42", "includes 42") { topic.includes(42) }

  assertion_test_fails("when 99 not included in array", "expected [1, 6, 42, 7] to include 99") do
    topic.includes(99)
  end
end # An includes assertion macro
