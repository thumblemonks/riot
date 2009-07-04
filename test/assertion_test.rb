require 'protest'

fake_context = Object.new

context "basic assertion:" do
  asserts("its description") do
    Protest::Assertion.new("i will pass", fake_context).to_s
  end.equals("i will pass")

  asserts("passed? if assertion returns true") do
    Protest::Assertion.new("i will pass", fake_context) { true }.passed?
  end

  asserts("failure? when assertion does not pass") do
    Protest::Assertion.new("i will pass", fake_context) { false }.failure?
  end

  asserts("error? when an unexpected Exception is raised") do
    Protest::Assertion.new("error", fake_context) { raise Exception, "blah" }.error?
  end
end

context "basic denial:" do
  asserts("false assertion passes") do
    Protest::Denial.new("i will pass", fake_context) { false }.passed?
  end

  asserts("true assertion fails") do
    Protest::Denial.new("i will not pass", fake_context) { true }.failure?
  end
end # basic assertion

context "equals assertion:" do
  asserts("results equals expectation") do
    Protest::Assertion.new("i will pass", fake_context) { "foo bar" }.equals("foo bar")
  end

  asserts("a Failure if results don't equal eachother") do
    Protest::Assertion.new("failure", fake_context) { "bar" }.equals("foo")
  end.kind_of(Protest::Failure)

  asserts("a non-matching string is a good thing when in denial") do
    Protest::Denial.new("pass", fake_context) { "bar" }.equals("foo")
  end.nil
end # equals assertion

context "nil assertion:" do
  asserts("actual result is nil") { Protest::Assertion.new("foo", fake_context) { nil }.nil }
  asserts("a Failure if not nil") do
    Protest::Assertion.new("foo", fake_context) { "a" }.nil
  end.kind_of(Protest::Failure)
end # nil assertion

context "raises assertion:" do
  asserts("an Exception is raised") { raise Exception }.raises(Exception)
end # maching assertion

context "matching assertion:" do
  asserts("actual result matches expression") do
    Protest::Assertion.new("foo", fake_context) { "a" }.matches(%r[.])
  end.equals(0)

  asserts("a Failure if not nil") do
    Protest::Assertion.new("foo", fake_context) { "" }.matches(%r[.])
  end.kind_of(Protest::Failure)

  asserts("string matches string") do
    Protest::Assertion.new("foo", fake_context) { "a" }.matches("a")
  end.equals(0)
end # maching assertion

context "kind_of assertion:" do
  asserts("result is kind of String") do
    Protest::Assertion.new("foo", fake_context) { "a" }.kind_of(String)
  end
  asserts("a Failure if not a kind of String") do
    Protest::Assertion.new("foo", fake_context) { 0 }.kind_of(String)
  end.kind_of(Protest::Failure)
end # kind_of assertion
