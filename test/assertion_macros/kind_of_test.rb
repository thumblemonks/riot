require 'teststrap'

context "A kind_of assertion macro" do
  setup { Riot::Situation.new }

  asserts ":pass when specific result is a kind of String" do
    Riot::Assertion.new("foo") { "a" }.kind_of(String).run(topic)
  end.equals([:pass, %Q{is a kind of String}])

  asserts ":fail when not a kind of String" do
    Riot::Assertion.new("foo") { 0 }.kind_of(String).run(topic)
  end.equals([:fail, %Q{expected kind of String, not Fixnum}])
  
  asserts ":fail when nil" do
    Riot::Assertion.new("foo") { }.kind_of(String).run(topic)
  end.equals([:fail, %Q{expected kind of String, not NilClass}])
end # A kind_of assertion macro
