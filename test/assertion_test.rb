require 'protest'

fake_context = Object.new # It works ... so, why not?

context "basic assertion:" do
  should "have a description" do
    Protest::Assertion.new("i will pass", fake_context).to_s
  end.equals("i will pass")

  asserts "pass? is true when assertion passed" do
    Protest::Assertion.new("i will pass", fake_context) { true }.passed?
  end

  asserts "failure? is true when assertion does not pass" do
    Protest::Assertion.new("i will pass", fake_context) { false }.failure?
  end

  asserts "error? is true when an unexpected Exception is raised" do
    Protest::Assertion.new("error", fake_context) { raise Exception, "blah" }.error?
  end
end

context "equals assertion:" do
  asserts "result equals expectation" do
    Protest::Assertion.new("i will pass", fake_context) { "foo bar" }.equals("foo bar")
  end

  should "raise a Failure if results don't equal each other" do
    Protest::Assertion.new("failure", fake_context) { "bar" }.equals("foo")
  end.kind_of(Protest::Failure)
end # equals assertion

context "nil assertion:" do
  asserts("result is nil") { Protest::Assertion.new("foo", fake_context) { nil }.nil }
  should "raise a Failure if not nil" do
    Protest::Assertion.new("foo", fake_context) { "a" }.nil
  end.kind_of(Protest::Failure)
end # nil assertion

context "raises assertion:" do
  should("raise an Exception") { raise Exception }.raises(Exception)
end # raises assertion

context "matching assertion:" do
  asserts "result matches expression" do
    Protest::Assertion.new("foo", fake_context) { "a" }.matches(%r[.])
  end.equals(0)

  should "raise a Failure if result does not match" do
    Protest::Assertion.new("foo", fake_context) { "" }.matches(%r[.])
  end.kind_of(Protest::Failure)

  should "return the result of a matching operation" do
    Protest::Assertion.new("foo", fake_context) { "a" }.matches("a")
  end.equals(0)
end # maching assertion

context "kind_of assertion:" do
  asserts "specific result is a kind of String" do
    Protest::Assertion.new("foo", fake_context) { "a" }.kind_of(String)
  end

  should "raise a Failure if not a kind of String" do
    Protest::Assertion.new("foo", fake_context) { 0 }.kind_of(String)
  end.kind_of(Protest::Failure)
end # kind_of assertion
