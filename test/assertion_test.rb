require 'protest'

fake_context = Object.new

context "basic assertion:" do
  asserts("its description").equals("i will pass") do
    Protest::Assertion.new("i will pass").to_s
  end

  asserts("true is expected") { Protest::Assertion.new("i will pass") { true }.run(fake_context) }

  asserts("a Failure if not true").raises(Protest::Failure) do
    Protest::Assertion.new("i will pass") { false }.run(fake_context)
  end

  asserts("an Exception error is thrown").raises(Exception) do
    Protest::Assertion.new("error") { raise Exception, "blah" }.run(fake_context)
  end
end # basic assertion

context "equals assertion:" do
  asserts("results equals expectation") do
    Protest::Assertion.new("i will pass").equals("foo bar") { "foo bar" }.run(fake_context)
  end

  asserts("a Failure if results don't equal eachother").raises(Protest::Failure) do
    Protest::Assertion.new("failure").equals("foo") { "bar" }.run(fake_context)
  end
end # equals assertion

context "nil assertion:" do
  asserts("actual result is nil") { Protest::Assertion.new("foo").nil { nil }.run(fake_context) }
  asserts("a Failure if not nil").raises(Protest::Failure) do
    Protest::Assertion.new("foo").nil { "a" }.run(fake_context)
  end
end # nil assertion

context "matching assertion:" do
  asserts("actual result matches expression").equals(0) do
    Protest::Assertion.new("foo").matches(%r[.]) { "a" }.run(fake_context)
  end
  asserts("a Failure if not nil").raises(Protest::Failure) do
    Protest::Assertion.new("foo").matches(%r[.]) { "" }.run(fake_context)
  end
  asserts("string matches string").equals(0) do
    Protest::Assertion.new("foo").matches("a") { "a" }.run(fake_context)
  end
end # maching assertion

context "kind_of assertion:" do
  asserts("result is kind of String") do
    Protest::Assertion.new("foo").kind_of(String) { "a" }.run(fake_context)
  end
  asserts("a Failure if not a kind of String").raises(Protest::Failure) do
    Protest::Assertion.new("foo").kind_of(String) { 0 }.run(fake_context)
  end
end # kind_of assertion

context "a passing denial" do
  asserts("that it is a failed assertion") do
    Protest::Denial.new("foo") { false }.run(fake_context)
  end
end # a passing denial
