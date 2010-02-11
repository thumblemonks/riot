require 'teststrap'

context "A not! assertion macro" do
  setup do
    def assert_not(value)
      Riot::Assertion.new("test") { value }.not!
    end
  end

  assertion_test_passes("when value is false", "does exist ... not!") { assert_not(false) }
  assertion_test_passes("when value is nil", "does exist ... not!") { assert_not(nil) }
  assertion_test_fails("when value is not nil or false", "expected to exist ... not!") do
    assert_not("funny")
  end
end # A not! assertion macro
