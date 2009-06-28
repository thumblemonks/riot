require 'test_helper'

context "any assertion" do
  asserts("its description").equals("i will pass: expected [true]") do
    Protest::Assertion.new("i will pass").to_s
  end
end # any assertion

context "passing assertion" do
  asserts("true is expected") do
    Protest::Assertion.new("i will pass") { true }.run(Object.new)
  end

  asserts("provided block was executed and returned true") do
    Protest::Assertion.new("i will pass").equals("foo bar") { "foo bar" }.run(Object.new)
  end

  asserts("false on denial") do
    Protest::Assertion.new("i will fail").not { false }.run(Object.new)
  end

  asserts("expectation does not equal actual result") do
    Protest::Assertion.new("i will fail").not.equals("foo") { "bar" }.run(Object.new)
  end
end # passing assertion

context "failing assertion" do
  setup do
    @expected_message = "test context asserted failure: expected [true], but received [false] instead"
    assertion = Protest::Assertion.new("failure") { false }
    begin
      assertion.run(Protest::Context.new("test context"))
    rescue Protest::Failure => e
      @result = e
    end
  end
  
  asserts("failure message").equals(@expected_message) do
    @result.to_s
  end
end # failing assertion
