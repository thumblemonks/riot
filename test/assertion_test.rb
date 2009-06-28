require 'test_helper'

context "any assertion" do
  setup { @assertion = Protest::Assertion.new("i will pass") }
  asserts("its description").equals("i will pass: expected [true]") { @assertion.to_s }
end

context "passing assertion" do
  setup do
    assertion = Protest::Assertion.new("i will pass") { true }
    @result = assertion.run(Object.new)
  end
  
  asserts("true is expected") { @result == true }
end

context "assertion with equals" do
  setup do
    assertion = Protest::Assertion.new("i will pass").equals("foo bar") { "foo bar" }
    @result = assertion.run(Object.new)
  end
  
  asserts("provided block was executed and returned true") { @result == true }
end

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
end
