require 'teststrap'

context "An any assertion macro" do
  setup do
    def assert_any(string)
      Riot::Assertion.new("test") { string }.any
    end
  end

  assertion_test_passes("when an array has items", "is not empty") { assert_any([1]) }
  assertion_test_fails("when an array is empty", "expected [] to have items") do
    assert_any([])
  end

  assertion_test_passes("when a hash has items", "is not empty") { assert_any({:name => 'washington'}) }
  assertion_test_fails("when a hash is empty", "expected {} to have items") do
    assert_any({})
  end
end
