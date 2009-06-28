require 'protest'

context "any assertion" do
  asserts("its description").equals("i will pass: expected [true]") do
    Protest::Assertion.new("i will pass").to_s
  end
end # any assertion

context "passing assertion" do
  asserts("true is expected") { Protest::Assertion.new("i will pass") { true }.run(Object.new) }
  asserts("false on denial") { Protest::Assertion.new("i will fail").not { false }.run(Object.new) }
  asserts("actual result is nil") { Protest::Assertion.new("i will fail").nil { nil }.run(Object.new) }

  asserts("provided block was executed and returned true") do
    Protest::Assertion.new("i will pass").equals("foo bar") { "foo bar" }.run(Object.new)
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
  asserts("failure message").equals(@expected_message) { @result.to_s }
end # failing assertion

context "erroring assertion" do
  setup do
    @expected_message = "test context asserted error: expected [true], but errored with: blah"
    assertion = Protest::Assertion.new("error") { raise Exception, "blah" }
    begin
      assertion.run(Protest::Context.new("test context"))
    rescue Protest::Error => e
      @result = e
    end
  end
  asserts("error message").equals(@expected_message) { @result.to_s }
end # failing assertion
