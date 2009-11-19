require 'teststrap'

context "kind_of assertion:" do
  setup { Riot::Situation.new }

  asserts "specific result is a kind of String" do
    Riot::Assertion.new("foo", topic) { "a" }.kind_of(String)
  end

  should "raise a Failure if not a kind of String" do
    Riot::Assertion.new("foo", topic) { 0 }.kind_of(String)
  end.kind_of(Riot::Failure)
end # kind_of assertion