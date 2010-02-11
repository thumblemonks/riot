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
