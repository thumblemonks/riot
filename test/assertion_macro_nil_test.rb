require 'teststrap'

context "nil assertion:" do
  setup { Riot::Situation.new }

  asserts("result is nil") do
    Riot::Assertion.new("foo", topic) { nil }.nil
  end

  should "raise a Failure if not nil" do
    Riot::Assertion.new("foo", topic) { "a" }.nil
  end.kind_of(Riot::Failure)
end # nil assertion

