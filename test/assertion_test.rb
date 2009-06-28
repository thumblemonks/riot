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

context "failing assertions:" do
  asserts("a Failure error is thrown").raises(Protest::Failure) do
    Protest::Assertion.new("failure") { false }.run(Object.new)
  end

  asserts("an Error error is thrown").raises(Protest::Error) do
    Protest::Assertion.new("error") { raise Exception, "blah" }.run(Object.new)
  end
end # failing assertions
