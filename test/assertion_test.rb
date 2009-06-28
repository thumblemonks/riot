require 'protest'

fake_object = Object.new

context "basic assertion:" do
  asserts("its description").equals("i will pass: expected [true]") do
    Protest::Assertion.new("i will pass").to_s
  end

  asserts("true is expected") { Protest::Assertion.new("i will pass") { true }.run(fake_object) }

  asserts("a Failure if not true").raises(Protest::Failure) do
    Protest::Assertion.new("i will pass") { false }.run(fake_object)
  end

  asserts("an Error error is thrown").raises(Protest::Error) do
    Protest::Assertion.new("error") { raise Exception, "blah" }.run(fake_object)
  end
end # basic assertion

context "equals assertion:" do
  asserts("provided block was executed and returned true") do
    Protest::Assertion.new("i will pass").equals("foo bar") { "foo bar" }.run(fake_object)
  end

  asserts("a Failure if results don't equal eachother").raises(Protest::Failure) do
    Protest::Assertion.new("failure").equals("foo") { "bar" }.run(fake_object)
  end
end # equals assertion

context "nil assertion:" do
  asserts("actual result is nil") { Protest::Assertion.new("foo").nil { nil }.run(fake_object) }
  asserts("a Failure if not nil").raises(Protest::Failure) do
    Protest::Assertion.new("foo").nil { "a" }.run(fake_object)
  end
end # nil assertion

# context "matching assertion:" do
#   asserts("actual result matches expression") do
#     Protest::Assertion.new("foo").matches(%r[.]) { "a" }.run(fake_object)
#   end
#   asserts("a Failure if not nil").raises(Protest::Failure) do
#     Protest::Assertion.new("foo").matches(%r[.]) { "" }.run(fake_object)
#   end
# end # nil assertion
