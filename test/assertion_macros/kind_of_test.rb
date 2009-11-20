require 'teststrap'

context "A kind_of assertion macro" do
  setup { Riot::Situation.new }

  asserts ":pass when specific result is a kind of String" do
    Riot::Assertion.new("foo") { "a" }.kind_of(String).run(topic)
  end.equals([:pass])

  asserts ":fail when not a kind of String" do
    Riot::Assertion.new("foo") { 0 }.kind_of(String).run(topic)
  end.equals([:fail, %Q{expected kind of String, not 0}])
end # A kind_of assertion macro