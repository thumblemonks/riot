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

context "A negative includes assertion macro" do
  setup do
    Riot::Assertion.new("an array", true) { [1, 6, 42, 7] }
  end
  
  assertion_test_passes("when array doesn't include 69", "includes 69") { topic.includes(69) }
  
  assertion_test_fails("when 42 is included in array", "expected [1, 6, 42, 7] to not include 42") do
    topic.includes(42)
  end
end
