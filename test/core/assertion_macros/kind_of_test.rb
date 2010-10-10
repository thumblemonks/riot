require 'teststrap'

context "A kind_of assertion macro" do
  assertion_test_passes(":pass when specific result is a kind of String", "is a kind of String") do
    Riot::Assertion.new("foo") { "a" }.kind_of(String)
  end

  assertion_test_fails(":fail when not a kind of String", "expected kind of String, not Fixnum") do
    Riot::Assertion.new("foo") { 0 }.kind_of(String)
  end

  assertion_test_fails(":fail when nil", "expected kind of String, not NilClass") do
    Riot::Assertion.new("foo") { }.kind_of(String)
  end
end # A kind_of assertion macro

context "A negative kind_of assertion macro" do
  assertion_test_passes(":pass when specific result is not a kind of String", "is not a kind of String") do
    Riot::Assertion.new("foo", true) { 1 }.kind_of(String)
  end
  
  assertion_test_fails(":fail when a kind of String", "expected not kind of String, not String") do
    Riot::Assertion.new("foo", true) { "a" }.kind_of(String)
  end

  assertion_test_passes(":pass when nil", "is not a kind of String") do
    Riot::Assertion.new("foo", true) { }.kind_of(String)
  end
  
end # A negative kind_of assert macro