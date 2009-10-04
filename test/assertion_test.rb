require 'riot'

fake_context = Object.new # It works ... so, why not?

context "basic assertion:" do
  should "have a description" do
    Riot::Assertion.new("i will pass", fake_context).to_s
  end.equals("i will pass")

  asserts "pass? is true when assertion passed" do
    Riot::Assertion.new("i will pass", fake_context) { true }.passed?
  end

  asserts "failure? is true when assertion does not pass" do
    Riot::Assertion.new("i will pass", fake_context) { false }.failed?
  end

  asserts "error? is true when an unexpected Exception is raised" do
    Riot::Assertion.new("error", fake_context) { raise Exception, "blah" }.errored?
  end
end

context "equals assertion:" do
  asserts "result equals expectation" do
    Riot::Assertion.new("i will pass", fake_context) { "foo bar" }.equals("foo bar")
  end

  should "raise a Failure if results don't equal each other" do
    Riot::Assertion.new("failure", fake_context) { "bar" }.equals("foo")
  end.kind_of(Riot::Failure)
end # equals assertion

context "nil assertion:" do
  asserts("result is nil") { Riot::Assertion.new("foo", fake_context) { nil }.nil }
  should "raise a Failure if not nil" do
    Riot::Assertion.new("foo", fake_context) { "a" }.nil
  end.kind_of(Riot::Failure)
end # nil assertion

context "raises assertion:" do
  should("raise an Exception") { raise Exception }.raises(Exception)

  should "pass if provided message equals expectation" do
    Riot::Assertion.new("foo", fake_context) do
      raise Exception, "I'm a nerd"
    end.raises(Exception, "I'm a nerd")
  end.equals(true)

  should "fail if provided message does not equal expectation" do
    Riot::Assertion.new("foo", fake_context) do
      raise(Exception, "I'm a nerd")
    end.raises(Exception, "But I'm not")
  end.kind_of(Riot::Failure)

  should "pass if provided message matches expectation" do
    Riot::Assertion.new("foo", fake_context) do
      raise(Exception, "I'm a nerd")
    end.raises(Exception, %r[nerd])
  end.equals(true)

  should "fail if provided message does not match expectation" do
    Riot::Assertion.new("foo", fake_context) do
      raise(Exception, "I'm a nerd")
    end.raises(Exception, %r[foo])
  end.kind_of(Riot::Failure)
end # raises assertion

context "matching assertion:" do
  asserts "result matches expression" do
    Riot::Assertion.new("foo", fake_context) { "a" }.matches(%r[.])
  end.equals(0)

  should "raise a Failure if result does not match" do
    Riot::Assertion.new("foo", fake_context) { "" }.matches(%r[.])
  end.kind_of(Riot::Failure)

  should "return the result of a matching operation" do
    Riot::Assertion.new("foo", fake_context) { "a" }.matches("a")
  end.equals(0)
end # maching assertion

context "kind_of assertion:" do
  asserts "specific result is a kind of String" do
    Riot::Assertion.new("foo", fake_context) { "a" }.kind_of(String)
  end

  should "raise a Failure if not a kind of String" do
    Riot::Assertion.new("foo", fake_context) { 0 }.kind_of(String)
  end.kind_of(Riot::Failure)
end # kind_of assertion
