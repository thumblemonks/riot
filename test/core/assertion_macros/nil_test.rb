require 'teststrap'

context "A nil assertion macro" do
  helper(:assert_nil) { |o| Riot::Assertion.new("foo") { o }.nil.run(Riot::Situation.new) }

  asserts(":pass when result is nil") { assert_nil(nil)       }.equals([:pass, "is nil"])
  asserts(":fail with message")       { assert_nil("a")[0..1] }.equals([:fail, %Q{expected nil, not "a"}])
end # A nil assertion macro

context "A negative nil assertion macro" do
  helper(:assert_not_nil) { |o| Riot::Assertion.new("foo", true) { o }.nil.run(Riot::Situation.new) }
  
  asserts(":pass when result is not nil") { assert_not_nil(1)         }.equals([:pass, "is not nil"])
  asserts(":fail with message")           { assert_not_nil(nil)[0..1] }.equals([:fail, %Q{expected not nil}])
end # A negative nil assertion macro